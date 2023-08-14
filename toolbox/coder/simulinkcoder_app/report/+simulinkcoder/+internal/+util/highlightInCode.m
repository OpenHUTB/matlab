function highlightInCode(model,varargin)













...
...
...
...
...
...
...
...
...
...
...
...
...

    mdl=model;
    action='highlight';
    cr=simulinkcoder.internal.Report.getInstance;

    if nargin==1
        cr.publish(mdl,action,'');
    else
        input=varargin{1};
        loc_checkInput(input);
        cr.publish(mdl,action,input);
    end

    function loc_checkInput(input)


        if~(isstruct(input)&&isfield(input,'title')&&isfield(input,'data'))
            DAStudio.error('SimulinkCoderApp:report:Highlight_InputType');
        end

        title=input.title;
        if~(ischar(title)||isstring(title))
            DAStudio.error('SimulinkCoderApp:report:Highlight_TitleType');
        end

        data=input.data;
        if~iscell(data)
            DAStudio.error('SimulinkCoderApp:report:Highlight_DataType');
        end

        for i=1:length(data)
            d=data{i};
            if~(isstruct(d)&&isfield(d,'file')&&isfield(d,'line'))
                DAStudio.error('SimulinkCoderApp:report:Highlight_DataType');
            end

            file=d.file;
            if~(ischar(file)||isstring(file))
                DAStudio.error('SimulinkCoderApp:report:Highlight_FileType');
            end

            line=d.line;
            if~(isnumeric(line)&&isscalar(line)&&line>0)
                DAStudio.error('SimulinkCoderApp:report:Highlight_LineType');
            end

            if isfield(d,'loc')
                loc=d.loc;
                if~(isnumeric(loc)&&all(size(loc)==[1,2])&&...
                    loc(1)>=0&&loc(2)>loc(1))
                    DAStudio.error('SimulinkCoderApp:report:Highlight_LocType');
                end
            end
        end