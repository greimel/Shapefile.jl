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
                       (shapefile.POLYGON, # single polygon, no holes
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior
                             ],
                            [0],
                            {'type':'Polygon','coordinates':[
                                [(1,1),(1,9),(9,9),(9,1),(1,1)],
                                ]}
                        ),
                       (shapefile.POLYGON, # single polygon, holes (ordered)
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior
                             (2,2),(4,2),(4,4),(2,4),(2,2), # hole 1
                             (5,5),(7,5),(7,7),(5,7),(5,5), # hole 2
                             ],
                            [0,5,5+5],
                            {'type':'Polygon','coordinates':[
                                [(1,1),(1,9),(9,9),(9,1),(1,1)], # exterior
                                [(2,2),(4,2),(4,4),(2,4),(2,2)], # hole 1
                                [(5,5),(7,5),(7,7),(5,7),(5,5)], # hole 2
                                ]}
                        ),
                       (shapefile.POLYGON, # single polygon, holes (unordered)
                            [
                             (2,2),(4,2),(4,4),(2,4),(2,2), # hole 1
                             (1,1),(1,9),(9,9),(9,1),(1,1), # exterior
                             (5,5),(7,5),(7,7),(5,7),(5,5), # hole 2
                             ],
                            [0,5,5+5],
                            {'type':'Polygon','coordinates':[
                                [(1,1),(1,9),(9,9),(9,1),(1,1)], # exterior
                                [(2,2),(4,2),(4,4),(2,4),(2,2)], # hole 1
                                [(5,5),(7,5),(7,7),(5,7),(5,5)], # hole 2
                                ]}
                        ),
                       (shapefile.POLYGON, # multi polygon, no holes
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior
                             (11,11),(11,19),(19,19),(19,11),(11,11), # exterior
                             ],
                            [0,5],
                            {'type':'MultiPolygon','coordinates':[
                                [ # poly 1
                                    [(1,1),(1,9),(9,9),(9,1),(1,1)],
                                ],
                                [ # poly 2
                                    [(11,11),(11,19),(19,19),(19,11),(11,11)],
                                ],
                                ]}
                        ),
                       (shapefile.POLYGON, # multi polygon, holes (unordered)
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior 1
                             (11,11),(11,19),(19,19),(19,11),(11,11), # exterior 2
                             (12,12),(14,12),(14,14),(12,14),(12,12), # hole 2.1
                             (15,15),(17,15),(17,17),(15,17),(15,15), # hole 2.2
                             (2,2),(4,2),(4,4),(2,4),(2,2), # hole 1.1
                             (5,5),(7,5),(7,7),(5,7),(5,5), # hole 1.2
                             ],
                            [0,5,10,15,20,25],
                            {'type':'MultiPolygon','coordinates':[
                                [ # poly 1
                                    [(1,1),(1,9),(9,9),(9,1),(1,1)], # exterior
                                    [(2,2),(4,2),(4,4),(2,4),(2,2)], # hole 1
                                    [(5,5),(7,5),(7,7),(5,7),(5,5)], # hole 2
                                ],
                                [ # poly 2
                                    [(11,11),(11,19),(19,19),(19,11),(11,11)], # exterior
                                    [(12,12),(14,12),(14,14),(12,14),(12,12)], # hole 1
                                    [(15,15),(17,15),(17,17),(15,17),(15,15)], # hole 2
                                ],
                                ]}
                        ),
                       (shapefile.POLYGON, # multi polygon, nested exteriors with holes (unordered)
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior 1
                             (3,3),(3,7),(7,7),(7,3),(3,3), # exterior 2
                             (4.5,4.5),(4.5,5.5),(5.5,5.5),(5.5,4.5),(4.5,4.5), # exterior 3
                             (4,4),(6,4),(6,6),(4,6),(4,4), # hole 2.1
                             (2,2),(8,2),(8,8),(2,8),(2,2), # hole 1.1
                             ],
                            [0,5,10,15,20],
                            {'type':'MultiPolygon','coordinates':[
                                [ # poly 1
                                    [(1,1),(1,9),(9,9),(9,1),(1,1)], # exterior 1
                                    [(2,2),(8,2),(8,8),(2,8),(2,2)], # hole 1.1
                                ],
                                [ # poly 2
                                    [(3,3),(3,7),(7,7),(7,3),(3,3)], # exterior 2
                                    [(4,4),(6,4),(6,6),(4,6),(4,4)], # hole 2.1
                                ],
                                [ # poly 3
                                    [(4.5,4.5),(4.5,5.5),(5.5,5.5),(5.5,4.5),(4.5,4.5)], # exterior 3
                                ],
                                ]}
                        ),
                       (shapefile.POLYGON, # multi polygon, holes incl orphaned holes (unordered), should raise warning
                            [(1,1),(1,9),(9,9),(9,1),(1,1), # exterior 1
                             (11,11),(11,19),(19,19),(19,11),(11,11), # exterior 2
                             (12,12),(14,12),(14,14),(12,14),(12,12), # hole 2.1
                             (15,15),(17,15),(17,17),(15,17),(15,15), # hole 2.2
                             (95,95),(97,95),(97,97),(95,97),(95,95), # hole x.1 (orphaned hole, should be interpreted as exterior)
                             (2,2),(4,2),(4,4),(2,4),(2,2), # hole 1.1
                             (5,5),(7,5),(7,7),(5,7),(5,5), # hole 1.2
                             ],
                            [0,5,10,15,20,25,30],
                            {'type':'MultiPolygon','coordinates':[
                                [ # poly 1
                                    [(1,1),(1,9),(9,9),(9,1),(1,1)], # exterior
                                    [(2,2),(4,2),(4,4),(2,4),(2,2)], # hole 1
                                    [(5,5),(7,5),(7,7),(5,7),(5,5)], # hole 2
                                ],
                                [ # poly 2
                                    [(11,11),(11,19),(19,19),(19,11),(11,11)], # exterior
                                    [(12,12),(14,12),(14,14),(12,14),(12,12)], # hole 1
                                    [(15,15),(17,15),(17,17),(15,17),(15,15)], # hole 2
                                ],
                                [ # poly 3 (orphaned hole)
                                    [(95,95),(97,95),(97,97),(95,97),(95,95)], # exterior
                                ],
                                ]}
                        ),
                       (shapefile.POLYGON, # multi polygon, exteriors with wrong orientation (be nice and interpret as such)
                            [(1,1),(9,1),(9,9),(1,9),(1,1), # exterior with hole-orientation
                             (11,11),(19,11),(19,19),(11,19),(11,11), # exterior with hole-orientation
                             ],
                            [0,5],
                            {'type':'MultiPolygon','coordinates':[
                                [ # poly 1
                                    [(1,1),(9,1),(9,9),(1,9),(1,1)],
                                ],
                                [ # poly 2
                                    [(11,11),(19,11),(19,19),(11,19),(11,11)],
                                ],
                                ]}
                        ),
                     ]