function [f,ax] = createFig(w_norm, h_norm, orientation)

if nargin==2
    orientation = 'portrait';
end

paperHeight = 25.4;
paperWidth = 14.3;
f=figure('Units', 'normalized', 'OuterPosition', [0 0 1 1], 'Position', [0 0 1 1], 'PaperType', 'a4', 'PaperOrientation', orientation);
% h_norm = 0.5;
% w_norm = 1;
x0 = (1-w_norm)/2;
y0 = (1-h_norm)/2;
set(f, 'PaperUnits', 'normalized', 'PaperPosition', [x0 y0 w_norm h_norm])
pu = get(f, 'PaperUnits');
pp = [0 0 paperWidth paperHeight];
set(f, 'Units', pu, 'Position', pp)
ax=gca;