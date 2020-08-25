# copied from 
# https://github.com/GeospatialPython/pyshp/blob/master/test_shapefile.py
# commit e5407f38c571029721d7aaa9cabca2aa7ecd9019

# define various test shape tuples of (type, points, parts indexes, and expected geo interface output)
geo_interface_tests = [ (shapefile.POINT, # point
                            [(1,1)],
                            [],
                            {'type':'Point','coordinates':(1,1)}
                        ),
                       (shapefile.MULTIPOINT, # multipoint
                            [(1,1),(2,1),(2,2)],
                            [],
                            {'type':'MultiPoint','coordinates':[(1,1),(2,1),(2,2)]}
                        ),
                       (shapefile.POLYLINE, # single linestring
                            [(1,1),(2,1)],
                            [0],
                            {'type':'LineString','coordinates':[(1,1),(2,1)]}
                        ),
                       (shapefile.POLYLINE, # multi linestring
                            [(1,1),(2,1), # line 1
                             (10,10),(20,10)], # line 2
                            [0,2],
                            {'type':'MultiLineString','coordinates':[
                                [(1,1),(2,1)], # line 1
                                [(10,10),(20,10)] # line 2
                                ]}
                        ),
using GeometryBasics



# Polygons 1, 2, 2u
ext1 = Point2.([(1,1),(1,9),(9,9),(9,1),(1,1)])
ext2 = Point2.([(11,11),(11,19),(19,19),(19,11),(11,11)])
ints1 = Vector{Point2{Int}}.([
    [(2,2),(4,2),(4,4),(2,4),(2,2)], # hole 1
    [(5,5),(7,5),(7,7),(5,7),(5,5)]  # hole 2
])
ints2 = Vector{Point2{Int}}.([
    [(12,12),(14,12),(14,14),(12,14),(12,12)], # hole 2
    [(15,15),(17,15),(17,17),(15,17),(15,15)]  # hole 2
])

# Polygon 1: single polygon, no holes
rings10 = [ext1]
poly10 = Polygon(ext1)

# Polygon 2: single polygon, holes (ordered)
rings1 = [ext1, ints1...]
poly1 = Polygon(ext1, ints1)

# Polygon 2u: single polygon, holes (unordered)
rings1_unordered = rings1[[2,1,3]]

# Polygon 3: multi polygon, no holes
poly20 = Polygon(ext2)
poly2 = Polygon(ext2, ints2)

rings3 = [ext1, ext2]
mpoly10 = MultiPolygon([poly10, poly20])

# Polygon 4: multi polygon, holes (unordered)
rings4 = [ext1, ext2, ints2..., ints1...]
mpoly1 = MultiPolygon([poly1, poly2])

# Polygon 6: multi polygon, nested exteriors with holes (unordered)
ext3 = Point2.([(3,3),(3,7),(7,7),(7,3),(3,3)])
ext4 = Point2.([(4.5,4.5),(4.5,5.5),(5.5,5.5),(5.5,4.5),(4.5,4.5)])
ints3 = Vector{Point2{Int}}.([ 
 [(4,4),(6,4),(6,6),(4,6),(4,4)],
 [(2,2),(8,2),(8,8),(2,8),(2,2)]
])

poly3 = Polygon(ext3, ints3)
poly40 = Polygon(ext4)

ring = [ext1, ext3, ext4, ints3...]

# error: need to convert to Float64!!
MultiPolygon([poly1, poly2, poly3, poly40]) 

# Polygon 7: multi polygon, holes incl orphaned holes (unordered), should raise warning
orphaned_hole = Point2.([(95,95),(97,95),(97,97),(95,97),(95,95)])
rings = [ext1, ext2, ints2..., 
 orphaned_hole, # orphaned hole, should be interpreted as exterior)
 ints1...
]

MultiPolygon([poly1, poly2, Polygon(orphaned_hole)])

# Polygon 8: multi polygon, exteriors with wrong orientation (be nice and interpret as such)
rings_reversed = reverse.([ext1, ext2])
# -> mpoly10
