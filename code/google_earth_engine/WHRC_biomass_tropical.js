// code used within Google Earth Engine

// export NASA aboveground carbon density for bhima region
// load region (previously imported to GEE as an asset using the region shapefile)
// 13.06.2025

var region = ee.FeatureCollection('projects/download-landsat-459212/assets/region') 

// var vectorsDraw = region.draw({color: '800080', strokeWidth: 1});
// Map.addLayer(vectorsDraw, {}, 'Study region');


var dataset = ee.Image('WHRC/biomass/tropical');
// Show results only over land.
var landMask = ee.Image('NOAA/NGDC/ETOPO1').select('bedrock').gt(0);
var liveWoodyBiomass = dataset.updateMask(landMask).clip(region);

var visParams = {
  min: 0,
  max: 350,
  palette: [
    'ffffff', 'ce7e45', 'df923d', 'f1b555', 'fcd163', '99b718', '74a901',
    '66a000', '529400', '3e8601', '207401', '056201', '004c00', '023b01',
    '012e01', '011d01', '011301'
  ],
};
Map.addLayer(
    liveWoodyBiomass, visParams, 'Aboveground Live Woody Biomass (Mg/ha)');



Export.image.toDrive({
  image: liveWoodyBiomass,
  description: 'WHRC_biomass_Mgha',
  folder: 'bhima_basin',
  scale: 500, //original scale
  region: region,
  maxPixels: 1e13 ,
  fileFormat: 'GeoTiff'
});