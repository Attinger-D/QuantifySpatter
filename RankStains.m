% RankStains: script that sorts stain by size, from large to small,
% and removes very small spots that cannot be safely distinguished from stains
% because of the finite resolution of the image

% remove stains that have solidity lower than a threshold
bb=[stains.Solidity];
stains=stains(bb>Solidity_threshold);

  %remove spots with widths smaller or equal to Pixels_Noise, defined in
  % DescribeQuant.m, as these spots could be noise rather than stains
  Not_Noise = [stains.MinorAxisLength]>= Pixels_Noise;
  stains=stains(Not_Noise);

  % Sort the structure by 'Size', from larger to smaller
[~, idx] = sort([stains.MinorAxisLength], 'descend');
stains = stains(idx);
