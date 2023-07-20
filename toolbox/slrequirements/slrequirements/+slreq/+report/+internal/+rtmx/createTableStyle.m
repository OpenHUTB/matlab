function stylerStr=createTableStyle()

    import slreq.report.internal.rtmx.*
    filename=fullfile(matlabroot,'toolbox','slrequirements',...
    'slrequirements','+slreq','+report','+internal','+rtmx','tableStyle.css');
    styleContent=fileread(filename);

    stylerStr=createCellStr('style',styleContent);
end

function out=locCreateStyleStr(selectorStr,varargin)
    attStr='';
    for index=1:2:length(varargin)
        attStr=sprintf('%s %s: %s;\n"',attStr,varargin{index},varargin{index+1});
    end

    out=sprintf('%s {\n%s}\n',selectorStr,attStr);
end