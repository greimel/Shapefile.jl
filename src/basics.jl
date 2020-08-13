using PolygonOps

function parts_polygon(points::Vector{Point}, parts::Vector{Int32})
    @show "HERE!!!!"
    exterior_pts = Vector{GB.Point{2, Float64}}[]
    interior_pts = Vector{GB.Point{2, Float64}}[]
    parts .+= 1
    push!(parts, length(points)+1)
    # - split points into parts (rings)
    # - determine if rings are exterior or interior (holes)
    for i in 1:(length(parts)-1)
        pts = collect(points[x] for x in parts[i]:parts[i+1]-1)
        if ring(pts)
            push!(exterior_pts, pts)
        else
            @assert hole(pts)
            push!(interior_pts, pts)
        end
    end

    if false #length(exterior_pts) == 0 && length(interior_pts) == 1
        polygons = [GB.Polygon(GB.LineString(only(interior_pts)))]
        @warn "hit special case"
    elseif length(exterior_pts) == 1 # need GB.Polygon
        @warn "hit normal case 1"
        exterior = GB.LineString(only(exterior_pts))
        if length(interior_pts) != 0
            interiors = collect(GB.LineString(pts) for pts in interior_pts)
            polygons = [GB.Polygon(exterior, interiors)]
        else
            polygons = [GB.Polygon(exterior)]
        end
    elseif length(exterior_pts) > 1 # need GB.MultiPolygon
        @warn "hit normal case 2"
        # 1) match exteriors with interiors
        if length(interior_pts) == 0
            polygons = GB.Polygon.(exterior_pts)
        else
            # for each interior return the index of containing exterior ring
            i_exterior_matched = map(interior_pts) do int
                pt_int = int[1]
                
                i_ext_matched = findfirst(eachindex(exterior_pts)) do i_ext
                    ext = exterior_pts[i_ext]
                    inpolygon(pt_int, ext) == 1 # TODO: function should return a Bool
                end
                
                @assert inpolygon(pt_int, exterior_pts[i_ext_matched])
                
                i_ext_matched
            end
            # 2) for each exterior collect all associated interiors
            polygons = map(enumerate(exterior_pts)) do (i_ext, ext)
                interiors = GB.LineString.(interior_pts[i_exterior_matched .== i_ext])
                exterior = GB.LineString(ext)
                GB.Polygon(exterior, interiors)
            end
        end
    else
        @error "reached unreachable"
    end

    return GB.MultiPolygon(polygons)

end

using ShiftedArrays
# check if non-convex polygon is clockwise: 
# https://stackoverflow.com/a/1165943/4984167
function f(edge)
    x1, y1 = edge[1]
    x2, y2 = edge[2]
    (x2 - x1) * (y2 + y1)
    #y1 * x2 - y2 * x1 # used in linked js code
end
function edges(pts)
    # if ring is closed, drop first point
    n = pts[1] == pts[end]
    pts_ = @view pts[n+1:end]
    zip(pts_, ShiftedArrays.circshift(pts_, -1)) # ShiftedArrays.circshift is lazy
end

clockwise(pts) = sum(f, edges(pts)) >= 0
ring(pts) = clockwise(pts)
hole(pts) = !clockwise(pts)

function parts_polyline(points::Vector{Point}, parts::Vector{Int32})
    linestrings = GB.LineString{2,Float64,GB.Point{2,Float64}}[]
    parts .+= 1
    for i in 1:length(parts)
        if length(parts) != 1 && i < length(parts)
            pts = collect(points[x] for x in parts[i]:parts[i+1]-1)
            push!(linestrings, GB.LineString(pts))
        elseif length(parts) == 1 && parts[1]==1
            push!(linestrings, GB.LineString(points))
        else
            pts = collect(points[x] for x in parts[i]:length(points))
            push!(linestrings, GB.LineString(pts))
        end
    end
    return GB.MultiLineString(linestrings) 
end
