function [blocks,charts] = machineLinkedCharts(machineId)
%

% This function was previously named as machine_linked_charts and was part
% of private/plc_mdl_check_initial_property.m

blocks = sf('get',machineId,'.sfLinks');
charts = zeros(size(blocks));

for idx=1:length(blocks)
    charts(idx) = sf('Private','block2chart',blocks(idx));
end
end