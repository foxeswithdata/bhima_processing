// code used within Google Earth Engine

// export NASA aboveground carbon density for bhima region
// load region (previously imported to GEE as an asset using the region shapefile)

var region = ee.FeatureCollection('projects/download-landsat-459212/assets/region') 

// var vectorsDraw = region.draw({color: '800080', strokeWidth: 1});
// Map.addLayer(vectorsDraw, {}, 'Study region');



var NASA_300m_Mgh = ee.ImageCollection('NASA/ORNL/biomass_carbon_density/v1')
.select('agb')
.toBands()
.clip(region);

print(NASA_300m_Mgh)


Export.image.toDrive({
  image: NASA_300m_Mgh,
  description: 'NASA_biomass_Mgha',
  folder: 'bhima_basin',
  scale: 300, //original scale
  region: region,
  maxPixels: 1e13 ,
  fileFormat: 'GeoTiff'
});