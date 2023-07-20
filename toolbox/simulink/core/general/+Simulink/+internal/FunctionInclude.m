




classdef FunctionInclude
    methods(Static)
        function includes=processIncludeFiles(varargin)
            assert(nargin==1);

            if isempty(varargin{1})
                includes=[];
                return;
            end

            if ischar(varargin{1})
                includeLocs=varargin(1);
            else
                includeLocs=varargin{1};
            end
            includes=l_processIncludeFiles(includeLocs);
        end
    end
end















function includes=l_processIncludeFiles(includeLocs)
    includes=[];
    for i=1:length(includeLocs)
        includeLoc=includeLocs{i};
        foundFile=which(includeLocs{i});
        if isempty(foundFile)
            continue;
        end
        [~,fileName,fileExt]=fileparts(foundFile);
        if isempty(fileExt)
            continue;
        end
        switch fileExt
        case '.mdl'
            fcns=readModelInterfaceFromLoadedModel(fileName);
        case{'.slx','.slxp'}
            fcns=readModelInterface(fileName,fileExt);
        otherwise
            fcns=readJSONInterface(includeLoc);
        end
        includes=[includes;fcns];%#ok
    end
end





function fcns=readModelInterfaceFromLoadedModel(model)
    bdH=[];%#ok
    if~bdIsLoaded(model)
        load_system(model);
        bdH=onCleanup(@()close_system(model,0));
    end
    fcns=l_findVisibleFunctions(model);
end




function fcns=readModelInterfaceFromSLXPart(model,ext)
    fcns=[];
    reader=Simulink.loadsave.SLXPackageReader(which([model,ext]));
    xmlTxt=reader.readPartToString('/simulink/modelDictionary.xml','UTF-8');
    if isempty(xmlTxt)
        return;
    end
    dictSys=Simulink.xml2DictionarySystem(xmlTxt);
    functionList=dictSys.Interface.Function.toArray;
    fcns=SLIDFcn2Struct(functionList);
    destroy(dictSys);

end






function fcns=readModelInterface(model,ext)
    if bdIsLoaded(model)
        fcns=readModelInterfaceFromLoadedModel(model);
    else
        fcns=readModelInterfaceFromSLXPart(model,ext);
    end
end




function fcns=readJSONInterface(includeLoc)
    fcns=jsondecode(fileread(includeLoc));
end


function fcns=l_findVisibleFunctions(model)

    model=get_param(model,'Name');



    blks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SystemType','SimulinkFunction');

    fcns=[];

    for i=1:length(blks)
        blk=blks{i};
        trig=find_system(blk,'SearchDepth',1,'BlockType','TriggerPort');


        fcns(end+1).Name=get_param(trig{1},'FunctionName');
        fcns(end).Prototype=get_param(blk,'FunctionPrototype');
        fcns(end).Visibility=get_param(trig{1},'FunctionVisibility');
        fcns(end).Arguments=[];

        argIns=find_system(blk,'SearchDepth',1,'BlockType','ArgIn');

        for j=1:length(argIns)
            argIn=argIns{j};

            fcns(end).Arguments(end+1).Name=get_param(argIn,'ArgumentName');
            fcns(end).Arguments(end).DataType=get_param(argIn,'OutDataTypeStr');
            fcns(end).Arguments(end).SignalType=get_param(argIn,'SignalType');
            fcns(end).Arguments(end).Dimensions=get_param(argIn,'PortDimensions');
        end

        argOuts=find_system(blk,'SearchDepth',1,'BlockType','ArgOut');

        for j=1:length(argOuts)
            argOut=argOuts{j};

            fcns(end).Arguments(end+1).Name=get_param(argOut,'ArgumentName');
            fcns(end).Arguments(end).DataType=get_param(argOut,'OutDataTypeStr');
            fcns(end).Arguments(end).SignalType=get_param(argOut,'SignalType');
            fcns(end).Arguments(end).Dimensions=get_param(argOut,'PortDimensions');
        end

    end
end


function fcns=SLIDFcn2Struct(functionList)
    numOfFcns=length(functionList);


    fcns=struct('Name',{},'Visibility',{},...
    'Prototype',{},'Arguments',{});
    if numOfFcns>0
        fcns(numOfFcns).Name=[];

        for fcnIdx=1:numOfFcns
            slidFcn=functionList(fcnIdx);
            slidArgs=slidFcn.Argument.toArray;
            numOfArgs=length(slidArgs);

            arguments=struct('Name',{},'DataType',{},...
            'Dimensions',{},'SignalType',{});
            if numOfArgs>0
                arguments(numOfArgs).Name=[];

                for argIdx=1:numOfArgs
                    slidArg=slidArgs(argIdx);
                    arguments(argIdx)=struct('Name',slidArg.Name,...
                    'DataType',slidArg.Type.NumericType,...
                    'Dimensions',slidArg.Type.Dimensions,...
                    'SignalType',slidArg.Type.Complexity);
                end
            end
            fcns(fcnIdx).Name=slidFcn.Name;
            fcns(fcnIdx).Prototype=slidFcn.Prototype;
            fcns(fcnIdx).Visibility=slidFcn.Visibility;
            fcns(fcnIdx).Arguments=arguments;
        end
    end
end


