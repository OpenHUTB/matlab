


classdef slcoderPublishCodeMetrics<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
    end
    methods
        function obj=slcoderPublishCodeMetrics(type,template,codemetrics,aReportInfo)
            ccm=codemetrics.Data;
            if isempty(ccm)
                codemetrics.createCodeMetricsData(aReportInfo);
                ccm=codemetrics.Data;
            end
            if isempty(ccm.FcnInfoMap)
                ccm.createFcnInfoMap();
            end
            if~strcmp(ccm.LatestStatus.Status,'successful')

                templatePath=coder.report.internal.slcoderPublishCode.getPrivateTemplatePath();
                template=fullfile(templatePath,'subchapter_template');
            end
            obj=obj@mlreportgen.dom.DocumentPart(type,template);
            obj.dataObj=codemetrics;
            obj.reportInfo=aReportInfo;
            obj.dataObj.initMessages();
        end

        function fillChapterTitle(obj)
            import mlreportgen.dom.*;
            obj.append(Text(DAStudio.message('RTW:report:CodeMetricsChapterTitle')));
        end

        function fillChapterIntroduction(obj)
            import mlreportgen.dom.*;
            ccm=obj.dataObj.Data;
            if strcmp(ccm.LatestStatus.Status,'failed')

                tf=ismember({ccm.LatestStatus.Reason.kind},'error');
                err_files={ccm.LatestStatus.Reason(tf).file};
                err_lines=cell(size(err_files));
                eLines=[ccm.LatestStatus.Reason(tf).line];
                for i=1:length(eLines)
                    err_lines{i}=int2str(eLines(i));
                end
                err_details={ccm.LatestStatus.Reason(tf).desc};
                [~,I]=unique(strcat(err_files,err_lines,err_details));
                table=Table([[obj.dataObj.msgs.file_msg,err_files(I)]',...
                [obj.dataObj.msgs.line_msg,err_lines(I)]',...
                [obj.dataObj.msgs.description_msg,err_details(I)]'],'TableStyleNormal');
                obj.append(Paragraph(obj.dataObj.msgs.fail_msg));
                obj.append(table);
                obj.append(Paragraph);
            elseif strcmp(ccm.LatestStatus.Status,'notSupportCPP')
                fileList=OrderedList;
                files=ccm.FileList;
                for i=1:length(files)
                    [~,~,ext]=fileparts(files{i});
                    if strcmpi(ext,'.cpp')
                        fileList.append(ListItem(files{i}));
                    end
                end
                obj.append(Paragraph(obj.dataObj.msgs.notSupportCPP_msg));
                obj.append(fileList);
            end
        end
        function fillHardwarePane(obj)
            import mlreportgen.dom.*;
            rtwcm=obj.dataObj.Data;
            if strcmp(get_param(rtwcm.getConfigsetObj,'ProdEqTarget'),'on')
                hardware_msg=sprintf(obj.dataObj.getMessage('HardwareType'),'Embedded');
            else
                hardware_msg=sprintf(obj.dataObj.getMessage('HardwareType'),'Emulation');
            end
            t=Text(hardware_msg);
            t.Style={Bold};
            obj.append(t);
        end
        function fillCharSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.CharNumBits)));
        end
        function fillShortSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.ShortNumBits)));
        end
        function fillIntSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.IntNumBits)));
        end
        function fillLongSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.LongNumBits)));
        end
        function fillFloatSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.FloatNumBits)));
        end
        function fillDoubleSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.DoubleNumBits)));
        end
        function fillPointerSize(obj)
            import mlreportgen.dom.*;
            obj.append(Text(num2str(obj.dataObj.Data.CodeMetricsOption.Target.PointerNumBits)));
        end
        function fillFileInformation(obj)
            obj.dataObj.fillFileInformation(obj);
        end
        function fillGlobalVariableInformation(obj)
            import mlreportgen.dom.*;
            ccm=obj.dataObj.Data;
            vars={ccm.GlobalVarInfo.Name};
            sizes=[ccm.GlobalVarInfo.Size];
            if ccm.hasKnownStat
                mdlRefVarList={ccm.KnownStat.GlobalVarInfo.Name};
                mdlRefVarSizes=[ccm.KnownStat.GlobalVarInfo.Size];
            else
                mdlRefVarList={};
                mdlRefVarSizes=[];
            end
            [mdlRefVars,tf]=setdiff(mdlRefVarList,vars);
            varCol=[vars,mdlRefVars];
            sizes=[sizes,mdlRefVarSizes(tf)];
            mdlref_name=cell(length(varCol),1);
            for i=1:length(vars)
                if ccm.GlobalVarInfo(i).IsStatic
                    var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(ccm.GlobalVarInfo(i).Name);
                else
                    var=vars{i};
                end
                mdlref_name{i}=' ';
                varCol{i}=var;
            end
            for i=1:length(mdlRefVars)
                [~,loc]=ismember(mdlRefVars{i},mdlRefVarList);
                varInfo=ccm.KnownStat.GlobalVarInfo(loc);
                refMdlName=varInfo.MdlRef;
                if varInfo.IsStatic
                    var=rtw.codemetrics.C_CodeMetrics.getIdentifierOrigName(varInfo.Name);
                else
                    var=varInfo.Name;
                end
                varCol{i+length(vars)}=var;
                mdlref_name{i+length(vars)}=refMdlName;
            end
            [sizes,I]=sort(sizes,'descend');
            varCol=varCol(I);
            mdlref_name=mdlref_name(I);
            option.HasHeaderRow=true;
            option.HasBorder=true;
            col1=[obj.dataObj.getMessage('GlobalVarHeaderText');varCol';obj.dataObj.getMessage('Total')];
            col2=[obj.dataObj.getMessage('VarSizeHeaderText');loc_int2str(sizes);loc_int2str(sum(sizes))];
            if length(col1)>1
                if isempty(mdlRefVars)
                    table=Table([col1,col2],'TableStyleAltRowRightAlign');
                else
                    col3=[obj.dataObj.getMessage('MdlrefHeaderText');mdlref_name;' '];
                    table=Table([col1,col2,col3],'TableStyleAltRowRightAlign');
                end
                obj.append(table);
            else
                obj.append(obj.dataObj.getMessage('NoGlobalVar'));
            end
        end
        function fillFunctionInformation(obj)
            import mlreportgen.dom.*;
            ccm=obj.dataObj.Data;
            fcns={ccm.FcnInfo.Name};
            n=length(fcns);
            col1=cell(n,1);
            col2=cell(n,1);
            col3=cell(n,1);
            col4=cell(n,1);
            col5=cell(n,1);
            col6=cell(n,1);
            col7=cell(n,1);
            nl=sprintf('\n');
            for i=1:length(fcns)
                fcnInfo=ccm.FcnInfo(i);
                if~isempty(fcnInfo.Caller)
                    col2{i}='';
                    for j=1:length(fcnInfo.Caller)
                        fcn=fcnInfo.Caller(j).Name;
                        nCalled=fcnInfo.Caller(j).Weight;
                        if nCalled>1
                            textFcn=[fcn,' (',int2str(nCalled),')'];
                        else
                            textFcn=fcn;
                        end
                        col2{i}=[col2{i},textFcn];
                        if i<length(fcnInfo.Caller)
                            col2{i}=[col2{i},nl];
                        end
                    end
                else
                    col2{i}='';
                end
                if fcnInfo.HasDefinition
                    col1{i}=fcnInfo.Name;
                    col5{i}=int2str(fcnInfo.NumCodeLines);
                    col6{i}=int2str(fcnInfo.NumTotalLines);
                    col7{i}=int2str(fcnInfo.Complexity);
                    col3{i}=int2str(fcnInfo.StackTotal);
                    if ismember(fcnInfo.Idx,ccm.RecursiveFcnIdx)
                        col3{i}=[col3{i},'*'];
                    end
                    col4{i}=int2str(fcnInfo.Stack);
                else
                    col1{i}=fcnInfo.Name;
                    col3{i}=obj.dataObj.getMessage('MissingDefText');
                    col4{i}='-';
                    col5{i}='-';
                    col6{i}='-';
                    col7{i}='-';
                end
            end
            [~,I]=sort(fcns);
            col1=col1(I);
            col2=col2(I);
            col3=col3(I);
            col4=col4(I);
            col5=col5(I);
            col6=col6(I);
            col7=col7(I);
            col3=strrep(col3,'-1',obj.dataObj.getMessage('Recursion'));
            table=Table([[obj.dataObj.getMessage('FcnNameHeaderText');col1],...
            [obj.dataObj.getMessage('FcnCalledByHeaderText');col2],...
            [obj.dataObj.getMessage('TotalStackHeaderText');col3],...
            [obj.dataObj.getMessage('LocalStackHeaderText');col4],...
            [obj.dataObj.getMessage('LOCHeaderText');col5],...
            [obj.dataObj.getMessage('LineHeaderText');col6],...
            [obj.dataObj.getMessage('ComplexityHeaderText');col7]],'TableStyleAltRowRightAlign');
            obj.append(table);
        end
    end
end





function s=loc_int2str(x)
    s=cell(length(x),1);
    for i=1:length(x)
        str=int2str(x(i));
        n=length(str);
        new_str='';
        while n>3
            new_str=[',',str(end-2:end),new_str];%#ok
            str=str(1:end-3);
            n=length(str);
        end
        if n>0
            new_str=[str,new_str];%#ok
        end
        s{i}=new_str;
    end
end

