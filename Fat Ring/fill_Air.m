function [ring1] = fill_Air(ring)
[y x] = size(ring);
ring1 = zeros(size(ring)+200);
ring1(101:y+100,101:x+100) = ring;
end