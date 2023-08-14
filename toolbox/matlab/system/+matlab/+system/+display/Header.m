classdef(Sealed)Header



























    properties



        Title;



        Text;





        ShowSourceLink;
    end

    properties(Access=private,Constant)
        FilteredWords={'#internal','#codegen'}
    end

    methods
        function obj=set.Title(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Title');


            if matlab.system.ui.isMessageID(v)
                locale=matlab.internal.i18n.locale('en_US');
                v=getString(message(v),locale);
            end

            obj.Title=v;
        end

        function obj=set.Text(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Text');
            obj.Text=v;
        end

        function obj=set.ShowSourceLink(obj,v)
            validateattributes(v,{'logical'},{'scalar'},'','ShowSourceLink');
            obj.ShowSourceLink=v;
        end

        function obj=Header(varargin)


            systemName='';
            if mod(numel(varargin),2)~=0
                systemName=varargin{1};
                if~matlab.system.display.isSystem(systemName)
                    error(message('MATLAB:system:unknownSystem',systemName));
                end
                PVArgs=varargin(2:end);
            else
                PVArgs=varargin;
            end


            p=inputParser;
            p.FunctionName='matlab.system.display.Header';
            p.addParameter('Title','');
            p.addParameter('Text','');
            p.addParameter('ShowSourceLink',true);
            p.parse(PVArgs{:});
            results=p.Results;


            if isstring(systemName)&&isscalar(systemName)
                systemName=char(systemName);
            end

            if~isempty(systemName)
                if ismember('Title',p.UsingDefaults)
                    defaultTitle=systemName;
                    ind=find(defaultTitle=='.',1,'last');
                    if~isempty(ind)&&(ind<length(defaultTitle))
                        defaultTitle=defaultTitle(ind+1:end);
                    end
                    results.Title=defaultTitle;
                end

                if ismember('Text',p.UsingDefaults)
                    results.Text=getSystemObjectDescription(systemName,obj.FilteredWords);
                end

                if ismember('ShowSourceLink',p.UsingDefaults)
                    if exist(which(systemName),'file')==6
                        defaultShowSourceLink=false;
                    else
                        defaultShowSourceLink=true;
                    end
                    results.ShowSourceLink=defaultShowSourceLink;
                end
            end


            obj.Title=results.Title;
            obj.Text=results.Text;
            obj.ShowSourceLink=results.ShowSourceLink;
        end
    end
end

function description=getSystemObjectDescription(className,filteredWords)

    description=strtrim(help(which(className),'-noDefault'));


    newLineIndex=regexp(description,'\r\n|\n','once');
    if~isempty(newLineIndex)
        description=description(1:newLineIndex);
    end


    description=strrep(description,'<strong>','');
    description=strtrim(strrep(description,'</strong>',''));



    description=replace(description,filteredWords,'');


    firstSpaceIndex=regexp(description,' ','once');
    if isempty(firstSpaceIndex)
        return;
    end
    leadToken=description(1:firstSpaceIndex-1);
    dotIndices=strfind(className,'.');
    if strcmpi(leadToken,className)||...
        (~isempty(dotIndices)&&strcmpi(leadToken,className(dotIndices(end)+1:end)))
        description=strtrim(description(firstSpaceIndex+1:end));
    end
end

