function [out] = hat_map(vec)
% Define the hat map of a vector

out = [0, -vec(3), vec(2); vec(3), 0, -vec(1); -vec(2), vec(1), 0];

