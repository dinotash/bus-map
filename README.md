# bus-map
Interactive visualization of the London bus network

Demo: http://www.dinotash.com/routemaster/

Click on any stop, and it will show you all the routes that stop there. Press + / - on the keyboard to zoom.

I wrote busMap using processing.js. It is available under an MIT licence. Data was provided by Transport for London.

----

DATA SOURCES

busMap relies on two sources of data provided in CSV format with a total size of 5.1MB. One has details of all the bus stops in London. The other has details of the stops that make up each bus route.

1) Bus stops (busStops.csv)

Each record in the bus stop data represents a stop. The LBSL code is a unique identifier for each stop. The bus stop code is a different identifier which passengers can use to obtain live updates of expected arrivals; it is displayed on a sign at each stop. The easting and northing give the Ordinance Survey grid reference for the location. Virtual bus stops were ignored.

The name includes details of other modes of transport available from a given stop:
 - <> = London Underground
 - # = National Rail
 - [DLR] or (DLR) = Docklands Light Railway
 - >T< or <T> = Croydon Tramlink
 - >R< or <R> = River Bus (i.e. boat)

2) Bus routes (busRoutes.csv)

Each record in the route data represents a stop along a route. The route is the number on the front of the bus. Even run numbers mean the stop is part of the outward leg of the route; odd numbers mean it is the return leg. The sequence gives the order of stops along the leg. LBSL codes were used to match this data to the canonical set of bus stops.

----

PROCESSING THE DATA

Each stop is represented as a busStop object recording the details imported from the data. Each route is represented as a busRoute object, with a number and a list of stops making up its outbound and return legs.

It then needs to work out where different buses share parts of their routes. To do this, it goes through each leg of each route and creates a series of stopPair objects, each representing the ends of a segment (e.g. route A->B->C involves the pairs A->B and B->C).

The program then uses each stopPair to create a list of stopPairRoute objects. Each stopPairRoute represents a unique stopPair plus a list of all the busRoute objects that pass through it.

For convenience, the code also records references to make drawing easier. Each busStop, for instance, has a pointer to each leg of each route and each stopPairRoute objects that pass through it.

----

DISPLAYING THE OUTPUT

When you click on a bus stop, two things happen. It draws the routes of all the buses that stop there, and it displays the information panel at the bottom. The panel is populated from the relevant busStop object.

To draw the routes, it loads the list of all the legs of all the routes that stop there. It loads the stopPairRoute for each part of each of those routes. Only routes that stop at your chosen stop will be drawn.

For each stop pair, it works out the vector from one end to the other. It also calculates the normal to that vector, so that it can show each bus going the same way side-by-side along the route.

For optimization, the code also checks and only tries to draw stops whose locations fit into the current display or links where one stop is on the screen. It updates these when you zoom or scroll.
