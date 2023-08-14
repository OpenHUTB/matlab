

function out=getModelName(report)
    [~,filename]=fileparts(report);
    out=filename(1:end-12);

end
