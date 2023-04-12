function [ pts ] = circEdgePt( xc, yc, rc, n, r, semi )
%CIRCEDGEPT returns n points of circles on the edge of the bounding circle.
%
%   circEdgePt returns a set of x y points that define the center of
%   circles (with radius r) bound by the circle defined from xc, yc, and
%   rc.
%
%   INPUTS:
%
%   xc                            X center of bounding circle
%
%
%   yc                            Y center of bounding circle
%
%
%   rc                            Radius of bounding circle
%
%
%   n                             Number of circles
%
%
%   r                             Radius of outputted circle
%
%
%   OUTPUTS:
%
%   pts                           Matrix of x and y points
%
%
%   AUTHOR:       Shant Malkasian
%   DATE CREATED: 19-Aug-2015
%
n = n+1;
angle_space = 2 * pi;
if semi
    angle_space = pi;
end
offset = .315 + pi/2;
a = linspace(offset , offset + angle_space, n);
rc = rc - 1.05*r;
pts = zeros(n,2);
for i=1:n
    [tempX,tempY] = helper(a(i),rc);
    pts(i,1) = round(tempX);
    pts(i,2) = round(tempY);
end
pts = pts(1:end-1,:);


    function [x,y]=helper(angle,radius)
        x=radius*cos(angle)+xc;
        y=radius*sin(angle)+yc;
    end

end
