












classdef DVGConverter<handle

    properties(SetAccess=?tUnitTestMaskToDVGConverter,Hidden=true)



        ToReturn=false;
        ToBreak=false;
        ToContinue=false;




        Variables=struct();





        ImageSavePath={'.'};









        MinX=Inf;
        MaxX=-Inf;
        MinY=Inf;
        MaxY=-Inf;


        BlockName='';


        SystemName='';


        InputLabelCount=0;
        OutputLabelCount=0;
        LConnCount=0;
        RConnCount=0;
        TopLabelCount=0;
        BottomLabelCount=0;


        PortCounts=struct();


        PortHandles=struct();


        BlockHandle=NaN;





        WasLoaded=false;


        Height=0;
        Width=0;





        Units='';



        PreProcessMode=false;


        SVGPath='';


        MaskDefinition='';


        ObjectHandle='';
    end

    properties

        success=false;


        SVGString='';




        ColorValue='';
    end

    methods(Access=?tUnitTestMaskToDVGConverter)


        svgString=process_disp(obj,params)


        svgString=process_dpoly(obj,params)


        svgString=process_droots(obj,params)


        svgString=process_fprintf(obj,params)


        svgString=process_image(obj,params)


        svgString=process_patch(obj,params)


        svgString=process_plot(obj,params)







        svgString=processPlotIndividual(obj,params,plotDetails)



        svgString=process_port_label(obj,params)



        svgString=process_text(obj,params)







        svgString=process_color(obj,params)






        svgString=processTextIndividual(obj,cmd,params)
    end

    methods


        function delete(obj)
            if(~obj.WasLoaded&&~isempty(obj.SystemName))
                splitBlock=strsplit(obj.SystemName,'/');
                close_system(splitBlock(1),0);
            end
        end


        function obj=DVGConverter()
        end




        function Initialize(obj,block)
            if(isnumeric(block))


                obj.BlockName=get_param(block,'Name');
            else



                splitBlock=strsplit(block,'/');
                systemName=splitBlock(1);




                obj.WasLoaded=bdIsLoaded(systemName);
                if(~obj.WasLoaded)
                    load_system(systemName);
                end
                obj.BlockName=get_param(block,'Name');
            end
            obj.SystemName=get_param(block,'Parent');
            obj.ObjectHandle=get_param(block,'MaskObject');
            obj.BlockHandle=get_param(block,'Handle');
            obj.MaskDefinition=get_param(block,'MaskDisplay');
            obj.Units=get_param(block,'MaskIconUnits');
            position=get_param(block,'position');
            obj.Height=position(4)-position(2);
            obj.Width=position(3)-position(1);
            obj.Variables=get_param(block,'MaskWSVariables');
            obj.PortHandles=get_param(block,'PortHandles');




            obj.LConnCount=numel(obj.PortHandles.Inport);
            obj.RConnCount=numel(obj.PortHandles.Outport);

            portCoutns=cellfun(@(x)numel(obj.PortHandles.(x)),fields(obj.PortHandles),...
            'UniformOutput',false);
            obj.PortCounts=cell2struct(portCoutns,fieldnames(obj.PortHandles));
        end

    end

    methods(Static)
        function svgString=ConvertMaskBlock(block,varargin)




































            converterObject=Simulink.Mask.DVGConverter();
            svgString=converterObject.DoConvertMaskBlock(block,varargin{:});
        end
    end

    methods(Access=private)


        function svgString=DoConvertMaskBlock(obj,block,varargin)
            mode='Capture';
            if(Simulink.Mask.determineMode(obj.MaskDefinition))
                mode='Mtree';
            end
            cellOut=Simulink.Mask.ParseArgs(mode,varargin{:});
            mode=cellOut{1};
            filename=cellOut{2};
            svgString='';

            try
                obj.Initialize(block);
                if(strcmpi(mode,'capture'))
                    obj.ConvertMaskBlockInCaptureMode();
                else
                    Simulink.Mask.Parse(obj);
                end
                if(~obj.success)
                    warning('Conversion of block has failed');
                    return;
                end
                svgString=obj.SVGString;
                if(~isempty(filename))
                    obj.success=Simulink.Mask.SaveToFile(svgString,filename);
                end
            catch ME
                warning(['Error occured while converting:',ME.message]);
                disp(struct2table(ME.stack));
                svgString='';
                return;
            end
        end



        function svgString=ConvertMaskBlockInCaptureMode(obj)
            try



                evaluatedCommandDetails=Simulink.Mask.getEvaluatedCommandsForDVGConversion(obj.ObjectHandle);



                exceptCommands={'hide_arrows','block_icon'};
                for i=evaluatedCommandDetails
                    commandName=i.Command;
                    args=i.Args;



                    if(strcmp('SetLimits',commandName))
                        obj.MinX=args(1);
                        obj.MinY=args(2);
                        obj.MaxX=args(3);
                        obj.MaxY=args(4);
                        continue;
                    end


                    matchedCommand=any(...
                    cellfun(@(x)strcmp(x,commandName),exceptCommands));




                    if(matchedCommand)
                        continue;
                    end



                    svgString=Simulink.Mask.DispatchCommand(obj,commandName,args);



                    obj.SVGString=[obj.SVGString,svgString];
                end
                svgString=Simulink.Mask.MakeSVG(obj);
                obj.success=true;
            catch ex
                svgString='';
                warning('Something went wrong when converting!');
                rethrow(ex);
            end
        end
    end

    methods(Access=public)

        function PreProcess(obj)







            if(strcmpi(obj.Units,'normalized'))

                obj.MinX=0;
                obj.MaxX=1;
                obj.MinY=0;
                obj.MaxY=1;
                return;
            elseif(strcmpi(obj.Units,'pixels'))



                obj.MinX=0;
                obj.MaxX=obj.Width;
                obj.MinY=0;
                obj.MaxY=obj.Height;
                return;
            end
            obj.PreProcessMode=true;





            savedVariables=obj.Variables;



            obj.EvaluateMtree(obj.MaskDefinition);



            obj.Variables=savedVariables;

            obj.PreProcessMode=false;
        end



        function svgString=EvaluateMtree(obj,mtreeString)
            svgString='';
            load_system(obj.SystemName);
            mtreeObj=mtree(mtreeString);

            mtreeNextObj=mtreeObj.setIX([1]);
            while(~isnull(mtreeNextObj))



                if(mtreeNextObj.iskind('IF'))
                    mtreeIfObj=mtreeNextObj.Arg;



                    while(~isnull(mtreeIfObj))















                        if(~isnull(mtreeIfObj.Left))
                            evalValue=obj.EvalExpression(tree2str(mtreeIfObj.Left));
                            if(evalValue{1})
                                svgString=[svgString,obj.EvaluateMtree(tree2str(mtreeIfObj.Body))];




                                if(obj.ToReturn||obj.ToBreak||obj.ToContinue)
                                    return;
                                end
                                break;
                            end
                        else




                            svgString=[svgString,obj.EvaluateMtree(tree2str(mtreeIfObj.Body))];
                            if(obj.ToReturn||obj.ToBreak||obj.ToContinue)
                                return;
                            end
                        end
                        mtreeIfObj=mtreeIfObj.Next;
                    end



                elseif(mtreeNextObj.iskind('FOR'))

                    variableName=tree2str(mtreeNextObj.Index);





                    arrayIndices=arrayfun(@(x)strcmp(x.Name,variableName),obj.Variables);




                    arrayPosition=sum(arrayIndices.*[1:numel(arrayIndices)]);
                    if(arrayPosition==0)

                        obj.Variables=[obj.Variables,...
                        struct('Name',variableName,'Value','')];
                        arrayPosition=numel(obj.Variables);
                    end



                    indexValues=obj.EvalExpression(tree2str(mtreeNextObj.Vector));
                    indexValues=indexValues{1};
                    forBody=mtreeNextObj.Body;
                    for i=indexValues


                        obj.Variables(arrayPosition).Value=i;



                        svgString=[svgString,obj.EvaluateMtree(tree2str(forBody))];


                        if(obj.ToReturn)
                            return;
                        elseif(obj.ToBreak)


                            obj.ToBreak=false;
                            break;
                        elseif(obj.ToContinue)


                            obj.ToContinue=false;
                        end
                    end



                elseif(mtreeNextObj.iskind('WHILE'))
                    expression=tree2str(mtreeNextObj.Left);
                    evalValue=obj.EvalExpression(expression);


                    while(evalValue{1})
                        whileBody=mtreeNextObj.Body;
                        svgString=[svgString,obj.EvaluateMtree(tree2str(whileBody))];

                        if(obj.ToReturn)
                            return;
                        elseif(obj.ToBreak)

                            obj.ToBreak=false;
                            break;
                        elseif(obj.ToContinue)
                            obj.ToContinue=false;
                        end
                        evalValue=obj.EvalExpression(expression);
                    end



                elseif(mtreeNextObj.iskind('SWITCH'))
                    variableName=tree2str(mtreeNextObj.Left);
                    caseBody=mtreeNextObj.Body;


                    while(~isnull(caseBody))

                        if(~isnull(caseBody.Left))
                            if(obj.SwitchCaseMatch(variableName,tree2str(caseBody.Left)))
                                svgString=[svgString,obj.EvaluateMtree(tree2str(caseBody.Body))];
                                break;
                            end


                        else
                            svgString=[svgString,obj.EvaluateMtree(tree2str(caseBody.Body))];
                            break;
                        end





                        if(obj.ToReturn||obj.ToBreak||obj.ToContinue)
                            return;
                        end
                        caseBody=caseBody.Next;
                    end








                elseif((mtreeNextObj.iskind('EXPR')||mtreeNextObj.iskind('PRINT'))&&...
                    mtreeNextObj.Arg.iskind('CALL')&&...
                    Simulink.Mask.CheckCommand(obj,mtreeNextObj.Arg.Left))
                    functionName=tree2str(mtreeNextObj.Arg.Left);
                    mtreeArgs=mtreeNextObj.Arg.Right;
                    argVals={};
                    while(~isnull(mtreeArgs))
                        argVals{numel(argVals)+1}=tree2str(mtreeArgs);
                        mtreeArgs=mtreeArgs.Next;
                    end

                    argString=strjoin(string(argVals),',');





                    if(obj.PreProcessMode)
                        svgString='';
                        obj.SetBoundaryValues(functionName,argString);
                    else
                        if(strcmp(functionName,'image'))

                            arguments=obj.EvalImageExpression(argString);
                        else

                            arguments=obj.EvalExpression(argString);
                        end
                        svgString=[svgString,obj.DispatchCommand(functionName,arguments)];
                        svgString=[svgString,'\n'];
                    end



                elseif(mtreeNextObj.iskind('BREAK'))
                    obj.ToBreak=true;
                    return;



                elseif(mtreeNextObj.iskind('RETURN'))
                    obj.ToReturn=true;
                    return;



                elseif(mtreeNextObj.iskind('CONTINUE'))
                    obj.ToContinue=true;
                    return;





                else
                    obj.HandleStatement(tree2str(mtreeNextObj.Arg));
                end


                mtreeNextObj=mtreeNextObj.Next;
            end
        end


        function SetBoundaryValues(obj,functionName,argString)
            args=obj.EvalExpression(argString);
            if(strcmp(functionName,'plot'))






                if(numel(args)>=4&&all(cellfun(@(x)isnumeric(x)&&(numel(x)==1),{args{1:4}})))

                    obj.MaxX=max(obj.MaxX,args{3});
                    obj.MaxY=max(obj.MaxY,args{4});
                    obj.MinX=min(obj.MinX,args{1});
                    obj.MinY=min(obj.MinY,args{2});
                    args=args(5:numel(args));
                end
            end
            if(strcmp(functionName,'plot'))





                maxXValue=max([args{1:2:numel(args)}]);


                obj.MaxX=max(obj.MaxX,maxXValue);




                minXValue=min([args{1:2:numel(args)}]);

                obj.MinX=min(obj.MinX,minXValue);




                maxYValue=max([args{2:2:numel(args)}]);
                obj.MaxY=max(obj.MaxY,maxYValue);




                minYValue=min([args{2:2:numel(args)}]);

                obj.MinY=min(obj.MinY,minYValue);

            elseif(strcmp(functionName,'patch'))
                obj.MaxX=max(obj.MaxX,max(args{1}));
                obj.MaxY=max(obj.MaxY,max(args{2}));
                obj.MinX=min(obj.MaxX,min(args{1}));
                obj.MinY=min(obj.MinY,min(args{2}));
            else
                return;
            end
        end



        function HandleStatement(obj,lineString)


            if(isempty(regexp(lineString,'gcbh','match')))
                lineString=regexprep(lineString,'gcb','Obj.BlockHandle');
            end
            mtreeObj=mtree(lineString);
            mtreeObj=mtreeObj.setIX(1);
            if(~isempty(Simulink.Mask.ReadFunctions(obj,mtreeObj)))


                warning('User defined functions are present here!');
            end
            if(mtreeObj.iskind('PRINT')&&...
                ~isnull(mtreeObj.Arg)&&...
                mtreeObj.Arg.iskind('EQUALS'))

                for variableNameValues=obj.Variables
                    try
                        if(count(mtfind(mtree(variableNameValues.Name),'Kind','ID'))>1)
                            VariableNames=strings(mtfind(mtree(variableNameValues.Name),'Kind','ID'));
                            for i=1:numel(VariableNames)
                                evalString=[string(VariableNames{i}),'= VariablesNameValues.Value(',string(i),repmat(',:',1,numel(size(variableNameValues.Value))-1),');'];
                                evalString=strjoin(evalString);
                                eval(char(evalString));
                            end
                        else
                            evalString=[string(variableNameValues.Name),'= VariablesNameValues.Value;'];
                            evalString=strjoin(evalString);
                            eval(char(evalString));
                        end
                    catch
                        warning('Adding parameters may have failed.');
                    end
                end

                clear EvalString VariablesNameValues;


                eval([lineString,';']);


                if(mtreeObj.Arg.Left.iskind('ID'))
                    assignedVariableName=tree2str(mtreeObj.Arg.Left);
                    if(~any(arrayfun(@(x)strcmp(x.Name,assignedVariableName),obj.Variables)))

                        obj.Variables=[obj.Variables,struct('Name',assignedVariableName,'Value','')];
                        eval(['obj.Variables(numel(obj.Variables)).Value = ',assignedVariableName,';']);
                    end
                elseif(mtreeObj.Arg.Left.iskind('LB'))
                    variableNamesArray=mtreeObj.Arg.Left.Arg;
                    while(~isnull(variableNamesArray))
                        assignedVariableName=tree2str(variableNamesArray);
                        if(~any(arrayfun(@(x)strcmp(x.Name,assignedVariableName),obj.Variables)))

                            obj.Variables=[obj.Variables,struct('Name',assignedVariableName,'Value','')];
                            eval(['obj.Variables(numel(obj.Variables)).Value = ',assignedVariableName,';']);
                        end
                        variableNamesArray=variableNamesArray.Next;
                    end
                elseif(mtreeObj.Arg.Left.iskind('DOT')&&...
                    mtreeObj.Arg.Left.Left.iskind('ID'))
                    assignedVariableName=tree2str(mtreeObj.Arg.Left.Left);
                    if(~any(arrayfun(@(x)strcmp(x.Name,assignedVariableName),obj.Variables)))

                        obj.Variables=[obj.Variables,struct('Name',assignedVariableName,'Value','')];
                        eval(['obj.Variables(numel(obj.Variables)).Value = ',assignedVariableName,';']);
                    end
                elseif(mtreeObj.Arg.Left.iskind('DOT')&&...
                    mtreeObj.Arg.Left.Left.iskind('SUBSCR')&&...
                    mtreeObj.Arg.Left.Left.Left.iskind('ID'))
                    assignedVariableName=tree2str(mtreeObj.Arg.Left.Left.Left);
                    if(~any(arrayfun(@(x)strcmp(x.Name,assignedVariableName),obj.Variables)))

                        obj.Variables=[obj.Variables,struct('Name',assignedVariableName,'Value','')];
                        eval(['obj.Variables(numel(obj.Variables)).Value = ',assignedVariableName,';']);
                    end
                end


                for i=1:numel(obj.Variables)
                    nameVariable=eval(char(strjoin(['obj.Variables(',string(i),').Name'])));
                    eval(char(strjoin(['obj.Variables(',string(i),').Value = ',nameVariable,';'])));
                end
            else


                if(~isempty(Simulink.Mask.ReadFunctions(obj,mtreeObj)))


                    warning('User defined functions are present here!');
                else
                    for variableNameValues=obj.Variables
                        try
                            evalString=[string(variableNameValues.Name),'= VariablesNameValues.Value;'];
                            evalString=strjoin(evalString);
                            eval(char(evalString));
                        catch
                            warning('Adding parameters may have failed.');
                        end
                    end
                    try
                        eval(lineString);
                    catch
                        warning('Somethingwent wrong with the conversion');
                    end
                end
            end
        end



        function SVGString=DispatchCommand(obj,functionName,commandArguments)
            SVGString=Simulink.Mask.DispatchCommand(obj,functionName,commandArguments);
        end





        function CellResult=EvalImageExpression(obj,lineExpression)
            CellResult=Simulink.Mask.EvalImageExpression(obj,lineExpression);
        end




        function CellResult=EvalExpression(obj,expressionString)
            CellResult=Simulink.Mask.EvalExpression(obj,expressionString);
        end



        function booleanResult=SwitchCaseMatch(obj,switchExpression,caseExpression)
            booleanResult=Simulink.Mask.SwitchCaseMatch(obj,switchExpression,caseExpression);
        end
    end
end