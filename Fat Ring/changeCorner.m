function [i1] = changeCorner(i)
%change the index 80 outside of the phantom to 10
i1 = i;
i1(i == 80) = 10;
end