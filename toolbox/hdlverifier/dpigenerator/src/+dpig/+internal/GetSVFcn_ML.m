


classdef GetSVFcn_ML<handle

    properties
        mCodeInfo;
        InitCall;
ResetCall
        OutputCall;
        TermCall;
    end

    properties(Constant)
        ObjHandle='objhandle';
        PostFix='_temp';
    end

    methods
        function obj=GetSVFcn_ML(codeInfo)
            obj.mCodeInfo=codeInfo;
        end

        function str=getAlwaysEventExpressionDecl(obj)
            str='';
            if strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')

                str=sprintf('always @(posedge %s or posedge %s) begin',...
                obj.getClockId,obj.getResetId);
            else

                for idx=1:obj.mCodeInfo.InStruct.NumPorts
                    decl=l_getInputPortDeclForEventExpression(obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}));
                    str=[str,decl];%#ok<AGROW>
                end

                str=str(1:end-2);
                str=sprintf('always @(%s) begin',str);
            end
        end

        function str=getPortDeclList(obj)
            str='';
            if strcmpi(obj.mCodeInfo.ComponentTemplateType,'sequential')

                for idx=1:length(obj.mCodeInfo.CtrlSigStruct)
                    CtrlSig_decl_temp=sprintf('%s %s %s,\n','input','bit',obj.mCodeInfo.CtrlSigStruct(idx).Name);
                    str=[str,CtrlSig_decl_temp];%#ok<AGROW>
                end
            end

            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                decl=l_getPortDecl(obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}),'');
                str=[str,'input ',decl,',',newline];%#ok<AGROW>
            end
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                decl=l_getPortDecl(obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}),'');
                str=[str,'output ',decl,',',newline];%#ok<AGROW>
            end

            if strcmpi(str(end),newline)
                str(end)=[];
            end

            if strcmpi(str(end),',')
                str(end)=[];
            end
        end

        function DeclareFcnStr=getImportInitializeFcn(obj)


            DeclareFcnStr=['import "DPI-C" function chandle ',obj.mCodeInfo.InitializeFcn.DPIName,'(input chandle existhandle);'];
            CallFcnStr=[obj.ObjHandle,'=',obj.mCodeInfo.InitializeFcn.DPIName,'(',obj.ObjHandle,');'];
            obj.InitCall=CallFcnStr;
        end

        function DeclareFcnStr=getImportResetFcn(obj)
            DeclareFcnStr='';
            if strcmpi(obj.mCodeInfo.ComponentTemplateType,'Sequential')

                [ArgumentsForDecl,ArgumentsForCalling]=l_getArgumentsList(obj,'Reset',obj.PostFix);
                DeclareFcnStr=['import "DPI-C" function chandle ',obj.mCodeInfo.ResetFcn.DPIName,'(input chandle ',obj.ObjHandle,ArgumentsForDecl];
                CallFcnStr=[obj.ObjHandle,'=',obj.mCodeInfo.ResetFcn.DPIName,'(',obj.ObjHandle,ArgumentsForCalling];
                obj.ResetCall=CallFcnStr;
            end
        end

        function DeclareFcnStr=getImportOutputFcn(obj)
            [ArgumentsForDecl1,ArgumentsForCalling1,ArgumentsForDecl2,ArgumentsForCalling2]=l_getArgumentsList(obj,'Output',obj.PostFix);
            if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
                DeclareFcnStr=sprintf('%s\n%s',['import "DPI-C" function void ',obj.mCodeInfo.OutputFcn.DPIRealNames{1},'(input chandle ',obj.ObjHandle,ArgumentsForDecl1],...
                ['import "DPI-C" function void ',obj.mCodeInfo.OutputFcn.DPIRealNames{2},'(',ArgumentsForDecl2]);
                CallFcnStr1=[obj.mCodeInfo.OutputFcn.DPIRealNames{1},'(',obj.ObjHandle,ArgumentsForCalling1];
                CallFcnStr2=[obj.mCodeInfo.OutputFcn.DPIRealNames{2},'(',ArgumentsForCalling2];
                obj.OutputCall={CallFcnStr1,CallFcnStr2};
            else
                DeclareFcnStr=['import "DPI-C" function void ',obj.mCodeInfo.OutputFcn.DPIName,'(input chandle ',obj.ObjHandle,ArgumentsForDecl1];
                CallFcnStr=[obj.mCodeInfo.OutputFcn.DPIName,'(',obj.ObjHandle,ArgumentsForCalling1];
                obj.OutputCall=CallFcnStr;
            end
        end

        function DeclareFcnStr=getImportUpdateFcn(~)
            DeclareFcnStr='';
        end

        function DeclareFcnStr=getImportAccessTestPointFcn(~)
            DeclareFcnStr='';
        end

        function DeclareFcnStr=getImportSetParamFcn(~,~)
            DeclareFcnStr='';
        end

        function DeclareFcnStr=getUpdateFcnCall(~)
            DeclareFcnStr='';
        end

        function DeclareFcnStr=getAccessTestPointFcnCall(~)
            DeclareFcnStr='';
        end

        function str=getAssertionSVPackageCode(~)
            str='';
        end

        function str=getAssertionQueryingSVCode(~)
            str='';
        end

        function str=getAssertionInfoStructDeclaration(~)
            str='';
        end

        function str=getDPIEntryPointWrapperFcnImpl(~,~)
            str='';
        end

        function str=getDPIEntryPointWrapperFcn(~,~)
            str='';
        end

        function str=getSVPortStructDef(~)
            str='';
        end

        function DeclareFcnStr=getImportTerminateFcn(obj)


            DeclareFcnStr=['import "DPI-C" function void ',obj.mCodeInfo.TerminateFcn.DPIName,'(input chandle existhandle);'];
            CallFcnStr=[obj.mCodeInfo.TerminateFcn.DPIName,'(',obj.ObjHandle,');'];
            obj.TermCall=CallFcnStr;
        end




        function str=getInitializeFcnCall(obj)
            str=obj.InitCall;
        end

        function str=getResetFcnCall(obj)
            str=obj.ResetCall;
        end

        function str=getOutputFcnCall(obj)
            if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
                str=sprintf('%s%s\n%s%s',obj.upperBoundCheckForVarSizeInput(),obj.getOutput1FcnCall(),...
                obj.allocateMemForVarSizeOutput,obj.getOutput2FcnCall);
            else
                str=obj.OutputCall;
            end
        end

        function str=getOutput1FcnCall(obj)
            str='';
            if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
                str=obj.OutputCall{1};
            end
        end

        function str=getOutput2FcnCall(obj)
            if obj.mCodeInfo.VarSizeInfo.containVarSizeOutput
                str=obj.OutputCall{2};
            end
        end

        function str=allocateMemForVarSizeOutput(obj)
            str='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx});
                if curPortInfo.IsVarSize
                    [~,argName]=l_getFcnArgDecl(curPortInfo);
                    str=sprintf('%s%s=new[%s];\n',str,[argName,obj.PostFix],[argName,'_size',obj.PostFix]);
                end
            end
        end

        function str=upperBoundCheckForVarSizeInput(obj)
            str='';
            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx});
                if curPortInfo.IsVarSize&&strcmpi(curPortInfo.VarSizeType,'upperBoundedArray')

                    [~,argName]=l_getFcnArgDecl(curPortInfo);
                    if curPortInfo.IsComplex
                        str=sprintf('%sassert(%s.size()<=%d) else $error("%s");\n',str,argName,curPortInfo.StructInfo.TopStructDim,...
                        message('HDLLink:DPIG:VariableSizedInputUpperBoundCheck',argName,curPortInfo.StructInfo.TopStructDim).getString);
                    else
                        str=sprintf('%sassert(%s.size()<=%d) else $error("%s");\n',str,argName,curPortInfo.Dim,...
                        message('HDLLink:DPIG:VariableSizedInputUpperBoundCheck',argName,curPortInfo.Dim).getString);
                    end
                end
            end
        end

        function str=getTerminateFcnCall(obj)
            str=obj.TermCall;
        end

        function str=destroySVOpenArrOutput(obj)
            str='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx});
                if curPortInfo.IsVarSize
                    [~,argName]=l_getFcnArgDecl(curPortInfo);
                    str=sprintf('%s%s;\n%s;\n',str,[argName,'.delete'],[argName,obj.PostFix,'.delete']);
                end
            end
        end

        function str=getEnumDeclarations(obj)
            str='';
            EnumTypeMap=containers.Map;

            for idx=1:obj.mCodeInfo.InStruct.NumPorts
                if obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}).IsEnum&&~isKey(EnumTypeMap,obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}).EnumInfo.EnumType)
                    str=sprintf('%s%s\n',str,n_getSVEnumDecl(obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}).EnumInfo));
                    EnumTypeMap(obj.mCodeInfo.PortMap(obj.mCodeInfo.InStruct.Port{idx}).EnumInfo.EnumType)=[];
                end
            end

            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                if obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}).IsEnum&&~isKey(EnumTypeMap,obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}).EnumInfo.EnumType)
                    str=sprintf('%s%s\n',str,n_getSVEnumDecl(obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}).EnumInfo));
                    EnumTypeMap(obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}).EnumInfo.EnumType)=[];
                end
            end

            function val=n_getSVEnumDecl(EnumInfo)
                EnumAccum='';
                cellfun(@(EStr,EVal)n_EnumAccum(EStr,EVal),EnumInfo.EnumStrVals,num2cell(EnumInfo.EnumIntVals));
                val=sprintf('typedef enum %s {%s} %s;',EnumInfo.EnumUnderlyingType,EnumAccum(1:end-1),EnumInfo.EnumType);
                function n_EnumAccum(EStr_,EVal_)
                    switch EnumInfo.EnumUnderlyingType
                    case{'byte','byte unsigned'}
                        BitWidth=8;
                    case{'shortint','shortint unsigned'}
                        BitWidth=16;
                    case{'int','int unsigned'}
                        BitWidth=32;
                    end

                    if EVal_<0
                        EnumAccum=sprintf('%s%s=-%d''d%d,',EnumAccum,EStr_,BitWidth,abs(EVal_));
                    else
                        EnumAccum=sprintf('%s%s=%d''d%d,',EnumAccum,EStr_,BitWidth,EVal_);
                    end
                end
            end
        end
    end


    methods
        function str=DeclarePortsInterface(obj)%#ok<MANU>
            str='';
        end

        function str=getImportTSVerifyFcn(obj)%#ok<MANU>
            str='';
        end

        function str=getTSVerifyPackageCode(obj)%#ok<MANU>
            str='';
        end

        function str=getTSVerifyInfoStructDeclaration(obj)%#ok<MANU>
            str='';
        end

        function str=getTSVerifyQueryingSVCode(obj)%#ok<MANU>
            str='';
        end

        function str=getTSVerifyInfoInstantiation(obj,varargin)%#ok<INUSD>
            str='';
        end

        function str=getTSVerifyInfoSetNewDPIObjHandle(obj,varargin)%#ok<INUSD>
            str='';
        end

        function str=getTSVerifyInfoReporting(obj)%#ok<MANU>
            str='';
        end
    end


    methods
        function str=getOutputTempVarDecl(obj)
            str='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                curPortInfo=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx});
                decl=l_getPortDecl(curPortInfo,obj.PostFix);
                str=sprintf('%s%s;\n',str,decl);
                if curPortInfo.IsVarSize


                    str=sprintf('%s%s;\n',str,['int ',curPortInfo.FlatName,'_size',obj.PostFix]);
                end
            end
        end

        function str=getNBVarAssignmentFromTmpToActual(obj)
            str='';
            for idx=1:obj.mCodeInfo.OutStruct.NumPorts
                FlatName=obj.mCodeInfo.PortMap(obj.mCodeInfo.OutStruct.Port{idx}).FlatName;
                str=sprintf('%s%s<=%s;\n',str,FlatName,[FlatName,obj.PostFix]);
            end
        end

        function str=getClockId(obj)


            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(1).Name);
        end

        function str=getClockEnId(obj)
            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(2).Name);
        end

        function str=getResetId(obj)
            str=sprintf('%s',obj.mCodeInfo.CtrlSigStruct(3).Name);
        end
    end
end

function str=l_getInputPortDeclForEventExpression(portInfo)
    dim=portInfo.Dim;
    str='';
    if~isempty(portInfo.StructInfo)&&nnz(portInfo.StructInfo.TopStructDim>1)>0

        for idx=1:prod([portInfo.StructInfo.TopStructDim,dim])
            str=sprintf('%s %s [%d] or',str,portInfo.FlatName,idx-1);
        end
    else
        if dim>1
            for idx=1:dim
                str=sprintf('%s %s [%d] or',str,portInfo.FlatName,idx-1);
            end
        else
            str=sprintf(' %s or',portInfo.FlatName);
        end
    end
end

function str=l_getPortDecl(portInfo,optionalPostFix)
    type=portInfo.SVDataType;
    dim=portInfo.Dim;





    if portInfo.IsVarSize
        str=sprintf('%s %s []',type,[portInfo.FlatName,optionalPostFix]);
    elseif~isempty(portInfo.StructInfo)&&nnz(portInfo.StructInfo.TopStructDim>1)>0

        str=sprintf('%s %s [%d:%d]',type,[portInfo.FlatName,optionalPostFix],0,prod([portInfo.StructInfo.TopStructDim,dim])-1);
    else
        if dim>1
            str=sprintf('%s %s [%d:%d]',type,[portInfo.FlatName,optionalPostFix],0,dim-1);
        else
            str=sprintf('%s %s',type,[portInfo.FlatName,optionalPostFix]);
        end
    end
end

function[str1,strCall1,str2,strCall2]=l_getArgumentsList(obj,fcnName,OutputPortsPostFix)
    portMap=obj.mCodeInfo.PortMap;
    str1=',';
    strCall1=',';
    str2='';
    strCall2='';

    for idx=1:obj.mCodeInfo.InStruct.NumPorts
        portInfo=portMap(obj.mCodeInfo.InStruct.Port{idx});
        [strTemp1,strCallTemp1]=l_getFcnArgDecl(portInfo);
        str1=[str1,strTemp1,','];%#ok<AGROW>
        strCall1=[strCall1,strCallTemp1,','];%#ok<AGROW>
    end

    for idx=1:obj.mCodeInfo.OutStruct.NumPorts
        portInfo=portMap(obj.mCodeInfo.OutStruct.Port{idx});
        if strcmpi(fcnName,'Output')
            [strTemp1,strCallTemp1]=l_getFcnArgDecl(portInfo,'Output1');
            [strTemp2,strCallTemp2]=l_getFcnArgDecl(portInfo,'Output2');
            if~isempty(strTemp2)
                str2=[str2,strTemp2,','];%#ok<AGROW>
                strCall2=[strCall2,[strCallTemp2,OutputPortsPostFix],','];%#ok<AGROW>
            end
        else
            [strTemp1,strCallTemp1]=l_getFcnArgDecl(portInfo);
        end
        str1=[str1,strTemp1,','];%#ok<AGROW>
        strCall1=[strCall1,[strCallTemp1,OutputPortsPostFix],','];%#ok<AGROW>
    end


    if str1(end)==','
        str1(end)=[];
    end
    str1=[str1,');'];

    if strCall1(end)==','
        strCall1(end)=[];
    end
    strCall1=[strCall1,');'];

    if~isempty(str2)
        str2(end)=[];
        strCall2(end)=[];
    end
    str2=[str2,');'];
    strCall2=[strCall2,');'];

end

function[str,strCall]=l_getFcnArgDecl(portInfo,varargin)
    type=portInfo.SVDataType;
    io=portInfo.Direction;
    dim=portInfo.Dim;
    fcnName='';
    str='';
    strCall='';
    if nargin>1
        fcnName=varargin{1};
    end













    if(portInfo.IsVarSize)
        if strcmpi(fcnName,'Output2')
            if strcmpi(io,'output')
                str=sprintf('%s %s %s []',io,type,portInfo.FlatName);
                strCall=sprintf('%s',portInfo.FlatName);
            end
        elseif strcmpi(fcnName,'Output1')&&strcmpi(io,'output')
            str=sprintf('%s int %s',io,[portInfo.FlatName,'_size']);
            strCall=sprintf('%s',[portInfo.FlatName,'_size']);
        else
            str=sprintf('%s %s %s []',io,type,portInfo.FlatName);
            strCall=sprintf('%s',portInfo.FlatName);
        end
    elseif~strcmpi(fcnName,'Output2')
        if~isempty(portInfo.StructInfo)&&nnz(portInfo.StructInfo.TopStructDim>1)>0

            str=sprintf('%s %s %s [%d]',io,type,portInfo.FlatName,prod([portInfo.StructInfo.TopStructDim,dim]));
        else
            if dim>1
                str=sprintf('%s %s %s [%d]',io,type,portInfo.FlatName,dim);
            else
                str=sprintf('%s %s %s',io,type,portInfo.FlatName);
            end
        end
        strCall=sprintf('%s',portInfo.FlatName);
    end
end

