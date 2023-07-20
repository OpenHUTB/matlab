function pcblayout(obj)
%PCBLAYOUT plots all the metal layers and the board shape
%
% pcblayout (hantenna) displays all the metal layers and the PCB shape in the
% figure window. The red filled circle correspond to the antenna feed
% points within the pcb stack and the blue filled squares correspond to the
% vias.
%
% Examples
%
% % Example 1: Create a default pcb stack, add a second feed at [0,0]
% % between layers 1 and 2, a via at [0, 0.01] between layers 1 and 2 and
% % visualize its layout.
%
% h = pcbStack;
% h.FeedLocations(2,:) = [0,0,1,2];
% h.ViaLocations(1,:) = [0,0.01,1,2];
% pcblayout(h)
%
%
% See also <a href="matlab:help em.MeshGeometry.mesh">mesh</a>,<a href="matlab:help em.MeshGeometry.show">show</a>

% Copyright 2018 The MathWorks, Inc.

hFig = gcf;
if ~isempty(get(groot,'CurrentFigure'))
    clf(hFig);
end
% Plot Shape and Metal layers
layerIndx = cellfun(@(x) isa(x,'antenna.Shape'),obj.Layers);
layerIndx = find(layerIndx);
legendStr = cell(1,numel(layerIndx)+1);
legendStr{1} = 'Board Shape';
plot(obj.BoardShape,'DisplayName',legendStr{1});
hax = gca;
hold(hax,'on');
for i = 2:numel(layerIndx)+1   
   legendStr{i} = ['Layer',num2str(layerIndx(i-1))];
   plot(obj.protectedMetalLayers{i-1},'DisplayName',legendStr{i}); 
end
% Plot Feed and Vias
fp = obj.FeedLocations(:,1:2);
plot(fp(:,1),fp(:,2),'o','MarkerEdgeColor','k',                         ...
    'MarkerFaceColor','r',                         ...
    'MarkerSize',8,                                ...
    'DisplayName','Feed');
xsign = sign(fp(:,1));
ysign = sign(fp(:,2));
xoffset = 0.08;
yoffset = 0.05;
text(hax,fp(:,1).*(1-xoffset),fp(:,2).*(1-yoffset),num2cell(1:size(fp,1)),'FontWeight',...
                                                          'Bold',...
                                                          'FontSize',...
                                                          13,...
                                                          'Color','k');
if ~isempty(obj.ViaLocations)
    vp = obj.ViaLocations(:,1:2);
    plot(vp(:,1),vp(:,2),'s','MarkerEdgeColor','k',                         ...
        'MarkerFaceColor','b',                         ...
        'MarkerSize',8,                                ...
        'DisplayName','Via');
end
hold(hax,'off')
hleg = legend;
hleg.Location = 'best';
xlabel('x (m)');
ylabel('y (m)');
title('PCB Stack Layout')
shg

end