
function boolString=CheckCommand(~,MTreeObj)
    stringValue=tree2str(MTreeObj);
    MatchStr=regexp(stringValue,...
    '^(color|disp|dpoly|droots|fprintf|image|patch|plot|port_label|text)$',...
    'ONCE');
    boolString=~isempty(MatchStr);
end