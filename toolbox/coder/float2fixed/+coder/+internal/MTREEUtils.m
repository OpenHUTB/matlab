


classdef MTREEUtils



    properties
    end

    methods(Static)
        function code=getFcnCode(fcnMtreeNode,indentLevel,replacements,includePrecedingComments)
            code=fcnMtreeNode.tree2str(indentLevel,1,replacements);

            if includePrecedingComments
                comments='';
                commentNode=fcnMtreeNode.previous;
                while~isempty(commentNode)&&strcmp(commentNode.kind,'COMMENT')
                    [originalIndent,~]=commentNode.getOriginalIndentString();
                    comment=commentNode.string;
                    comments=[originalIndent,comment,char(10),comments];
                    commentNode=commentNode.previous;
                end

                [signatureIndent,sameLine]=fcnMtreeNode.getOriginalIndentString();
                if sameLine

                end

                if~isempty(comments)
                    code=[comments,signatureIndent,code];
                else
                    code=[signatureIndent,code];
                end
            end
        end

        function[inputParamNames,outputParamNames,inputNodes,outputNodes]=fcnInputOutputParamNames(fcnNode)
            insR=fcnNode.Ins;
            numIns=count(insR.List);

            inputNodes=cell(1,numIns);
            inputParamNames=cell(1,numIns);

            for i=1:numIns
                inputNodes{i}=insR;

                if(iskind(insR,'NOT'))
                    inputParamNames{i}='~';
                else
                    inputParamNames{i}=insR.string;
                end

                insR=insR.Next;
            end

            outsR=fcnNode.Outs;
            numOut=count(outsR.List);

            outputNodes=cell(1,numOut);
            outputParamNames=cell(1,numOut);

            for i=1:numOut
                outputNodes{i}=outsR;

                if(iskind(insR,'NOT'))
                    outputParamNames{i}='~';
                else
                    outputParamNames{i}=outsR.string;
                end

                outsR=outsR.Next;
            end
        end

        function[inputParamNames,outputParamNames]=getFcnInputOutputParamNames(filePath,fcnNode)
            insR=fcnNode.Ins;
            numIns=count(insR.List);
            inputParamNames=cell(1,numIns);

            for i=1:numIns
                if(iskind(insR,'NOT'))
                    error(message('Coder:FXPCONV:unUsedInputorOutputFound',coder.internal.Helper.getPrintLinkStr(filePath,insR)));
                end
                inputParamNames{i}=insR.string;
                insR=insR.Next;
            end

            outsR=fcnNode.Outs;
            numOuts=count(outsR.List);
            outputParamNames=cell(1,numOuts);

            for i=1:numOuts
                if(iskind(insR,'NOT'))
                    error(message('Coder:FXPCONV:unUsedInputorOutputFound',coder.internal.Helper.getPrintLinkStr(filePath,insR)));
                end
                outputParamNames{i}=outsR.string;
                outsR=outsR.Next;
            end
        end



        function calleeInCount=getCalleeArgsCount(callNode)

            arg=callNode.Right;
            calleeInCount=0;
            while(~isempty(arg))
                calleeInCount=calleeInCount+1;
                arg=arg.Next;
            end
        end


        function fcnInCount=getFcnParamCount(fcnNode)
            in=fcnNode.Ins;
            fcnInCount=0;
            while(~isempty(in))
                fcnInCount=fcnInCount+1;
                prevIn=in;
                in=in.Next;
            end
            if(1==strcmp(prevIn.string,'varargin'))
                fcnInCount=-1;
            end
        end



        function outputCount=getOutputParams(callNode)
            equalsNode=callNode.Parent;
            if(equalsNode.Left.iskind('LB'))
                outputCount=count(equalsNode.Left.Arg.list);
            else
                outputCount=1;
            end
        end

        function[output,inOutParams]=hasInOutParams(fileNameWithPath)
            output=false;
            fileMTree=mtree(fileread(fileNameWithPath));
            subTF=mtfind(fileMTree,'Kind','FUNCTION');
            if(~isnull(subTF))
                indices=subTF.indices;
                FcnIndex=indices(1);
                FcnNode=subTF.select(FcnIndex);

                [inVars,outVars]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(fileNameWithPath,FcnNode);















                inOutParams=intersect(inVars,outVars);
                if(~isempty(inOutParams))
                    output=true;
                end
            end
        end


        function[output,isFunction,inputParams]=hasInputParams(tree)
            output=false;
            isFunction=false;
            inputParams=[];
            subTF=mtfind(tree,'Kind','FUNCTION');
            if(~isnull(subTF))
                isFunction=true;
                indices=subTF.indices;
                FcnIndex=indices(1);
                FcnNode=subTF.select(FcnIndex);

                inputParams=FcnNode.Ins;
                if~isempty(inputParams)
                    output=true;
                end
            end
        end


        function code=removeClearAll(tree)
            replacements={};
            dcallNodes=mtfind(tree,'Kind','DCALL');
            dindices=dcallNodes.indices;

            for i=1:length(dindices)
                index=dindices(i);
                callNode=dcallNodes.select(index);
                callee=string(callNode.Left);
                if strcmp(callee,'clear')
                    callExprText=callNode.tree2str(0,1,{});



                    if~isempty(strfind(callExprText,'all'))
                        replacements{end+1}=callNode;
                        replacements{end+1}=['%clear all;',char(10)];
                    end
                end
            end

            code=tree.tree2str(0,1,replacements);
        end


        function code=commentAllAsserts(tree)
            replacements={};
            dcallNodes=mtfind(tree,'Kind','CALL');
            dindices=dcallNodes.indices;

            for i=1:length(dindices)
                index=dindices(i);
                callNode=dcallNodes.select(index);
                callee=string(callNode.Left);
                if strcmp(callee,'assert')
                    callExprText=callNode.tree2str(0,1,{});
                    replacements{end+1}=callNode;
                    replacements{end+1}=['%',callExprText];
                end
            end

            code=tree.tree2str(0,1,replacements);
        end

        function code=changeIdInFile(tree,origId,newId)
            replacements={};
            ids=mtfind(tree,'Kind','ID');
            indices=ids.indices;
            for i=1:length(indices)
                index=indices(i);
                idNode=ids.select(index);
                if strcmp(strtrim(string(idNode)),origId)
                    replacements{end+1}=idNode;
                    replacements{end+1}=newId;
                end
            end
            code=tree.tree2str(0,1,replacements);
        end

        function[hasInput,hasOutput,isFunction]=InputAndOutputParams(fcnMtree)
            hasInput=false;
            hasOutput=false;
            isFunction=false;
            subTF=mtfind(fcnMtree,'Kind','FUNCTION');
            if(~isnull(subTF))
                isFunction=true;
                indices=subTF.indices;
                FcnIndex=indices(1);
                FcnNode=subTF.select(FcnIndex);

                inParam=FcnNode.Ins;
                outParam=FcnNode.Outs;
                if(~isempty(inParam))
                    hasInput=true;
                end
                if(~isempty(outParam))
                    hasOutput=true;
                end
            end
        end



        function[inputArgNames,outputArgNames]=parseDesignFcn(hFunctionName,hFunctionMT)


            fcnName=hFunctionName;
            coder.internal.Helper.checkFileExists(fcnName);
            fcnPath=coder.internal.Helper.which(fcnName);


            rootFcnMT=root(hFunctionMT);

            [inputArgNames,outputArgNames]=coder.internal.MTREEUtils.getFcnInputOutputParamNames(fcnPath,rootFcnMT);


















            numOut=length(outputArgNames);
            numIn=length(inputArgNames);

            outSig='';
            if numOut>0
                if numOut==1
                    outSig=[outputArgNames{1},' = '];
                else
                    outSig='[';
                    for ii=1:numOut
                        outSig=[outSig,outputArgNames{ii}];
                        if ii~=numOut
                            outSig=[outSig,', '];
                        end
                    end
                    outSig=[outSig,'] = '];
                end
            end

            inSig='';
            if numIn>0
                if numIn==1
                    inSig=['(',inputArgNames{1},')'];
                else
                    inSig='(';
                    for ii=1:numIn
                        inSig=[inSig,inputArgNames{ii}];
                        if ii~=numIn
                            inSig=[inSig,', '];
                        end
                    end
                    inSig=[inSig,')'];
                end
            end

        end



        function[msgs]=validateScript(hScriptName,hFunctionName,hDebugLevel,supportMLXTB)
            if nargin<4
                supportMLXTB=false;
            end

            msgs=coder.internal.lib.Message().empty();




            if any(strcmpi(hFunctionName,hScriptName))
                error(message('Coder:FXPCONV:invalidesignandtb'));
            end




            if isempty(hScriptName)
                error(message('Coder:FXPCONV:missingscript'));
            end

            [~,scriptName,fcnExt]=fileparts(hScriptName);

            validExt={'.m'};
            if supportMLXTB
                validExt{end+1}='.mlx';
            end

            inValidExt=~isempty(fcnExt)&&~any(strcmpi(fcnExt,validExt));
            if inValidExt
                error(message('Coder:FXPCONV:invalidScriptExt'));
            end

            try
                coder.internal.Helper.checkFileExists(scriptName);
            catch ex
                if strcmp(ex.identifier,'Coder:FXPCONV:BADFILENAME')
                    msgID='Coder:FXPCONV:testbenchNotFound';
                    msgSTR=message(msgID,hScriptName).getString();
                    tbDoesntExistEx=MException(msgID,msgSTR);
                    throw(tbDoesntExistEx);
                else
                    rethrow(ex);
                end
            end

            if~isempty(scriptName)
                fileName=coder.internal.Helper.which(scriptName);
            end

            fid=coder.internal.safefopen(fileName);
            if(fid==-1)
                error(message('Coder:FXPCONV:cannotopenscript',fileName));
            end

            hDirName=pwd;
            fullPath=fullfile(hDirName,fileName);
            if hDebugLevel>0
                disp(sprintf('\n%s  <a href="matlab:edit %s">%s</a>',message('Coder:FxpConvDisp:FXPCONVDISP:parsingtb').getString,fullPath,scriptName));%#ok<DSPS>
            end




            fclose(fid);





            scriptBody=fileread(fileName);
            mTS=mtree(scriptBody);
            [res,isFunction,inputParams]=coder.internal.MTREEUtils.hasInputParams(mTS);
            if(isFunction&&res)

                msgObj=message('Coder:FXPCONV:tbmustbescript',scriptName);
                txtLen=inputParams.rightposition-inputParams.leftposition+1;
                msgs(end+1)=getMessage(scriptName,fileName,msgObj,inputParams.leftposition,txtLen);
            end

            function[msg]=getMessage(scriptName,scriptPath,messageObj,leftPos,len)

                msg=coder.internal.lib.Message();
                msg.functionName=scriptName;%#ok<*AGROW>

                msg.specializationName=scriptName;%#ok<*AGROW>
                msg.file=scriptPath;
                msg.type='Error';
                msg.position=leftPos;
                msg.length=len;
                msg.text=messageObj.getString();
                msg.id=messageObj.Identifier;
                msg.params=messageObj.Arguments;
            end
        end

        function designMTree=validateDesign(hFunctionName,hDebugLevel)
            hDirName=pwd;




            fcnName=hFunctionName;

            if isempty(fcnName)
                error(message('Coder:FXPCONV:nofcnname'));
            end



            fileName=coder.internal.Helper.which(fcnName);

            [~,fcnFileName,fcnExt]=fileparts(fileName);

            coder.internal.Helper.checkFileExists(fcnFileName);

            if~isempty(fcnExt)&&~strcmpi(fcnExt,'.m')
                if strcmp(fcnExt,['.',mexext])
                    error(message('Coder:FXPCONV:invalidMexFcnExt',fileName,fcnFileName,sprintf('which(''%s'', ''-all'')',fcnFileName)));
                else
                    error(message('Coder:FXPCONV:invalidFcnExt',fileName));
                end
            end

            fid=coder.internal.safefopen(fileName);
            if(fid==-1)
                error(message('Coder:FXPCONV:cannotOpenFcn',fileName));
            end

            fullPath=fullfile(hDirName,fileName);
            if hDebugLevel>0
                disp(sprintf('\n%s <a href="matlab:edit %s">%s</a>',message('Coder:FxpConvDisp:FXPCONVDISP:parsingdesign').getString,fullPath,fcnName));
            end

            fcnBody=fileread(fileName);

            fclose(fid);




            mTF=mtree(fcnBody);
            subTF=mtfind(mTF,'Kind','FUNCTION');
            if isempty(subTF.strings)
                error(message('Coder:FXPCONV:designmustbefcn'));
            end

            designMTree=mTF;
        end


        function res=isclass(filepath)
            mt=mtree(fileread(filepath));
            classNode=mt.find('Kind','CLASSDEF');

            if~isempty(classNode)
                res=false;
                return;
            end

            res=true;
        end



        function globalNodes=getPersistentNodes(mt)
            assert(isa(mt,'mtree'));
            globalNodes=list(mt.find('Kind','ID','Parent.Kind','PERSISTENT'));
        end



        function globalNodes=getGlobalNodes(mt)
            assert(isa(mt,'mtree'));
            globalNodes=list(mt.find('Kind','ID','Parent.Kind','GLOBAL'));
        end



        function fcnNode=getFcnNodeMatching(nodes,fcnName)
            fcnNode=[];
            fcns=mtfind(nodes,'Kind','FUNCTION');
            indices=fcns.indices;
            for i=1:length(indices)
                index=indices(i);
                node=fcns.select(index);
                fn=string(node.Fname);
                if strcmp(fn,fcnName)
                    fcnNode=node;
                    return;
                end
            end
        end
    end

end

