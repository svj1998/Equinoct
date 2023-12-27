
clear
close all
clc

fnam = dir('*.nc');   % Get list of nc files in the folder
fnam = {fnam.name}';  % Extract the names of nc files
shapefile = "F:\Data\India-State-and-Country-Shapefile-Updated-Jan-2020-master\India_Landmass_WGS.shp"; %Location of Shapefile of India Land Mass
shapeData = shaperead(shapefile);  % Read Shape file
lon = shapeData.X(~isnan(shapeData.X));  % Get longitude of all vertices of Shapefile
lat = shapeData.Y(~isnan(shapeData.Y));  % Get latitude of all vertices of Shapefile

ncFile = fnam{1};  % extract basic info from first nc file, to reduce operations inside the loop
lonData = ncread(ncFile, 'lon');  % Reading longitude from nc file
latData = ncread(ncFile, 'lat');  % Reading latitude from nc file

lonIndex = find(lonData >= min(lon)-.5 & lonData <= max(lon)+.5);  % Finding latitudes from nc file that are inside a rectangle that bounds the shape file
latIndex = find(latData >= min(lat)-.5 & latData <= max(lat)+.5);  % Finding longitudes from nc file that are inside a rectangle that bounds the shape file
[lx,ly] = meshgrid(lonData(lonIndex),latData(latIndex));  % Meshing lat and lon
lx = reshape(lx,length(lonIndex)*length(latIndex),1);  % reshaping to an array
ly = reshape(ly,length(lonIndex)*length(latIndex),1);  % reshaping to an array

[mx,my] = meshgrid(lonIndex,latIndex);  % Meshing indices of lat and lon
mx = reshape(mx,length(lonIndex)*length(latIndex),1);
my = reshape(my,length(lonIndex)*length(latIndex),1);

[in,on] = inpolygon(lx,ly,shapeData.X,shapeData.Y);  % Identify lat lon points that are inside the polygon
indx = find(in);
extx = mx(indx); % Extract index of lon inside the shapefile
exty = my(indx); % Extract index of lat inside the shapefile

for e = 1:length(fnam)
    ncFile = fnam{e};  %loop through nc files in folder
    fl = 1; % flag variable
    data = [];
    p = ncread(ncFile,'pr'); % Read precipitation from nc file
    for k = 1:length(extx) % loop through all points inside the shapefile polygon
            dt(:,fl) = squeeze(p(extx(k),exty(k),:)); % change 3d matrix to 2d [lat lon converted to single series]
            fl = fl+1;
    end
    
   prec = mean(dt,2); % Find spatial mean of all prec points inside the shapefile
   dt = [];
   plot(prec,'LineWidth',2) % Ploting monthly values
   lent(e) = {extractBefore(fnam{e},'_')}; % Recording entries for legend
   hold on
end

legend(lent)  % Adding legend to figure
ylabel('Mean Precipitation') % adding label to y axis
xlabel('Months'); % adding label to x axis

xticks([1:12])  % Adding months as tic labels for x axis
xticklabels(datestr(datetime(1,[1:12],1),'mmm'))
xlim([1,12])

title('Precipitation Monthly Average') % Adding title




