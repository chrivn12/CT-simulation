function centerPts = getCentersWithoutOverlaps(numCenters, radius, x0, y0) 
    radius2 = (radius+40).^2; % radius of insert
    center = zeros(numCenters+1,2);
    center(1,:) = [x0, y0]; % first center
    ii = 2;
    while ii<=numCenters+1
       t = 2*pi*rand(1);
%        r = (300-50)*sqrt(rand(1))+50; % 50-300 before 10/27/2022, iv
%        contrast has wrong diameter
       r = (150-25)*sqrt(rand(1))+25; % 25-150
       tmp = [x0+r.*cos(t), y0+r.*sin(t)]; 
       iteration = 0;
       % keep generating a random number until
       % the new center is separated by "radius" from any other center points.
       while (any(sum((center(1:ii-1,:)-tmp).^2,2) < radius2)) && (iteration<1000) 
           t = 2*pi*rand(1);
           r = (150-25)*sqrt(rand(1))+25; % 25-150
           tmp = [x0+r.*cos(t), y0+r.*sin(t)];
           iteration = iteration + 1;
       end 
       % if the condition is met, the new center is added to "centers"
       if iteration<1000
           center(ii,:) = tmp;
           ii = ii + 1;
       else
           ii = 2;
           center = zeros(numCenters+1,2);
           center(1,:) = [x0, y0];
       end
    end
    centerPts = center(2:end,:);
end