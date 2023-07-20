classdef opcountbase<handle











    properties(Hidden,Access=protected)
        verbose='off';
        inst_level=1;
        ismatlab=false;
        issimulink=false;
        method='';
        input_path='';
        input_name='';
        input_ext='';
        input_arg={};
        output_dir='';
        incl_op={};
        incl_op_regexp={};
        excl_op={};
        excl_op_regexp={};
        incl_path={};
        incl_path_regexp={};
        excl_path={};
        excl_path_regexp={};
        build_dir='';
        entry_path='';
        matlab_path='';
        nidb;
        db_connect;
        result_data={};
        excl_internal_func={};
        mdlMap=containers.Map;
    end
    properties(Hidden,Access=public)
        noutput_arg=0;
    end


    methods
        function obj=opcountbase(method,input_path,input_name,input_ext,input_arg,output_dir,incl_op,excl_op,incl_path,excl_path,inst_level,verbose)

            try
                obj.input_path=input_path;
                obj.input_name=input_name;
                obj.input_ext=input_ext;

                switch(input_ext)
                case '.m'
                    obj.ismatlab=true;
                case{'.slx','.mdl'}
                    obj.issimulink=true;
                otherwise
                    error(message('shared_opcount:base:NotMLSL',obj.input_name));
                end

                obj.method=method;
                obj.input_arg=input_arg;
                obj.output_dir=output_dir;
                obj.incl_op=incl_op;
                obj.excl_op=excl_op;
                obj.incl_path=incl_path;
                obj.excl_path=excl_path;
                obj.excl_path=[obj.excl_path,obj.excl_internal_func];

                if~isempty(obj.incl_op)
                    obj.incl_op_regexp=regexprep(obj.incl_op,'[!?@#$%^&*()+=\-*/{}[]|\\:;<>,.]','\\$0');
                end
                if~isempty(obj.excl_op)
                    obj.excl_op_regexp=regexprep(obj.excl_op,'[!?@#$%^&*()+=\-*/{}[]|\\:;<>,.]','\\$0');
                end

                if~isempty(obj.incl_path)
                    obj.incl_path_regexp=regexprep(obj.incl_path,'[!?@#$%^&*()+=\-*/{}[]|\\:;<>,.]','\\$0');
                end
                if~isempty(obj.excl_path)
                    obj.excl_path_regexp=regexprep(obj.excl_path,'[!?@#$%^&*()+=\-*/{}[]|\\:;<>,.]','\\$0');
                end


                obj.inst_level=inst_level;
                obj.verbose=verbose;

                obj.setup_outputdir();

                obj.setup_builddir();
                internal.cgir.Debug.enable;
                obj.setup_nidb();

            catch ME
                rethrow(ME);
            end
        end

        function exec_generation(obj)
            try
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:GeneratingCode');
                    disp(msg.getString);
                end

                if obj.ismatlab
                    obj.mex_generation();
                end

                if obj.issimulink
                    obj.sl_generation();
                end
            catch ME
                rethrow(ME);
            end
        end

        function varargout=db_generation(obj)
            try
                varargout={};

                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:GeneratingDB');
                    disp(msg.getString);
                end

                if obj.ismatlab
                    varargout=cell(1,obj.noutput_arg);
                    [varargout{1:end}]=obj.mex_execution();
                end

                if obj.issimulink
                    obj.sl_execution();
                end
            catch ME
                rethrow(ME);
            end
        end

        function result=db_postprocessing(obj)
            try
                result={};
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:PostprocessingDB');
                    disp(msg.getString);
                end

                db_open(obj,obj.nidb.Filename);

                obj.data_collection();
            catch ME
                rethrow(ME);
            end
            result=obj.result_data;
        end

        function report=report_generation(obj)
            try
                report=struct;
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:GeneratingReport');
                    disp(msg.getString);
                end

                title='SoC Algorithm Analyzer Report';
                gen_date=datestr(datetime);
                src_type='';
                if obj.ismatlab
                    src_type='Function';
                end
                if obj.issimulink
                    src_type='Model';
                end
                a_method=obj.method;
                src_file=[obj.input_name,obj.input_ext];
                save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'title','gen_date','src_type','src_file','a_method');

                [drs,dr]=obj.detailed_report();

                [ohrs,ohr]=obj.operator_hierarchical_report();

                [oars,oar]=obj.operator_aggregated_report();

                [phrs,phr]=obj.path_hierarchical_report();

                [pars,par]=obj.path_aggregated_report();

                if~(oars||drs||pars)
                    if~strcmp(obj.verbose,'quiet')
                        msg=message('shared_opcount:base:NoReport');
                        disp(msg.getString);
                    end
                    return;
                end

                if~strcmp(obj.verbose,'quiet')
                    msg=message('shared_opcount:base:SavingReport',obj.output_dir);
                    disp(msg.getString);
                end

                obj.copy_output();

                str='';
                if ohrs||phrs
                    str='Operator estimate: ';
                    str=[str,'<a href="matlab: socAlgorithmAnalyzerReport(''',fullfile(obj.output_dir,[obj.input_name,'.mat']),''')">Open report viewer</a> '];
                end

                if drs
                    report.OperatorDetailedReport=dr;
                end

                if oars
                    report.OperatorAggregatedReport=oar;
                end

                if ohrs
                    report.OperatorHierarchicalReport=ohr;
                end

                if pars
                    report.PathAggregatedReport=par;
                end

                if phrs
                    report.PathHierarchicalReport=phr;
                end
                if~strcmp(obj.verbose,'quiet')
                    disp(str);
                end

            catch ME
                rethrow(ME);
            end
        end

    end

    methods(Hidden,Access=protected)
        function setup_nidb(obj)
            x=internal.cgir.Debug;
            x.NodeInfoDatabaseController.Enabled=1;
            obj.nidb=x.NodeInfoDatabaseController;
            switch(obj.method)
            case{'dynamic','Dynamic'}
                obj.nidb.Mode='Dynamic';
            case{'static','Static'}
                obj.nidb.Mode='Static';
            otherwise
                error(message('shared_opcount:base:NotValidMethod',obj.method));
            end
            obj.nidb.FunctionExcludeRegex='.*(emlrt|emx|eml_size_ispow2|indexShapeCheck|SLibCGIRIsSampleHit|OpaqueTLCBlockFcnNoSE|toLogicalCheck|SLibCGIRZCFcn|utAssert|rtIsNaN|rtIsInf|rtForLoopVectorCheck|rtSubAssignSizeCheckND|rtSizeEqCheckND|rtSizeEqCheck1D|rtDimSizeGeqCheck|InitializeConditions|coreInitializeConditions|coreOutputs|Update|coreUpdate|isnan|toLogicalCheck|all_in_integer_range|fltpower_domain_error|OpaqueTLCBlockFcnForMdlRefNoSE).*';
            obj.nidb.Operators={'CONDITIONAL_EXPR','LOGICAL_AND_EXPR','LOGICAL_OR_EXPR','LOGICAL_NOT_EXPR','BITWISE_AND_EXPR','BITWISE_OR_EXPR','BITWISE_XOR_EXPR','BITWISE_NOT_EXPR','ADD_EXPR','DIVISION_EXPR','MINUS_EXPR','MODULO_EXPR','MULTIPLY_EXPR','MATRIX_MULTIPLY_EXPR','EQUAL_EXPR','NOT_EQUAL_EXPR','LESS_EXPR','LESS_OR_EQUAL_EXPR','GREATER_EXPR','GREATER_OR_EQUAL_EXPR','SHIFT_LEFT_EXPR','SHIFT_RIGHT_EXPR','SHIFT_RIGHT_LOGICAL_EXPR','SHIFT_RIGHT_ARITHMETIC_EXPR','UNARY_MINUS_EXPR','PRE_INCREMENT_EXPR','POST_INCREMENT_EXPR','PRE_DECREMENT_EXPR','POST_DECREMENT_EXPR','CALL_EXPR','MULTI_OUTPUT_CALL_EXPR'};
            obj.nidb.Filename=fullfile(obj.build_dir,[obj.input_name,'.db']);
            obj.nidb.TransformRegex='(CGIR[.])?EarlyProfiling';
            obj.nidb.PathRegex='.*';
            obj.nidb.PathExcludeRegex='(.*[\\/]matlab[\\/](.*[\\/])?toolbox[\\/](eml|shared[\\/]coder|fixedpoint[\\/]fixedpoint[\\/][+]fixed[\\/][+]internal)[\\/].*)';

            obj.nidb.clearNodeInfo;




        end
        function mex_generation(obj)

            config=coder.config('mex');
            config.CustomInitializer='emlrtProfilingStart(); emlrtProfilingClear();';
            config.CustomTerminator='emlrtProfilingSave(); emlrtProfilingFinish();';
            config.EnableOpenMP=false;
            config.SaturateOnIntegerOverflow=false;
            config.IntegrityChecks=false;
            config.PreserveVariableNames='UserNames';
            config.PreserveArrayDimensions=true;



            feature=coder.internal.FeatureControl;
            feature.EnableBLAS=0;
            featureCleanup=onCleanup(@()internal.cgir.Debug.disable);

            if 1

                coder.internal.generateAlgorithmAnalyzer(obj.input_name,'-args',obj.input_arg,'-config',config,'-feature',feature,'-O','disable:inline','tpb3379334_563d_4394_b05f_26c58924749e');
            else
                codegen(obj.input_name,'-g','-args',obj.input_arg,'-config',config,'-feature',feature,'-O','disable:inline');
            end
            obj.nidb.writeNodeInfo;
            obj.noutput_arg=nargout(obj.input_name);
        end

        function varargout=mex_execution(obj)

            if(ispc())
                exec_name=fullfile(obj.build_dir,[obj.input_name,'_mex.mexw64']);
            else
                exec_name=fullfile(obj.build_dir,[obj.input_name,'_mex.mexa64']);
            end

            timeout=10;
            while~exist(exec_name,'file')
                if timeout<=0
                    error(message('shared_opcount:base:NoExec'));
                end
                pause(1);
                timeout=timeout-1;
            end


            origEnv=getenv('CGIR_PROFILING_DETAILED');
            envCleanup=onCleanup(@()setenv('CGIR_PROFILING_DETAILED',origEnv));
            setenv('CGIR_PROFILING_DETAILED','1');
            varargout=cell(1,obj.noutput_arg);
            [varargout{1:end}]=feval([obj.input_name,'_mex'],obj.input_arg{:});

            timeout=10;

            while~exist(obj.nidb.Filename,'file')
                if timeout<=0
                    error(message('shared_opcount:base:NoDB'));
                end
                pause(1);
                timeout=timeout-1;
            end

            clear([obj.input_name,'_mex']);
        end

        function sl_generation(obj)

            load_system(obj.input_name);

            mdls=find_mdlrefs(obj.input_name,'MatchFilter',@Simulink.match.allVariants,'IncludeProtectedModels',true);

            obj.mdlMap=containers.Map;
            for ii=1:numel(mdls)
                [~,name,~]=fileparts(mdls{ii});
                mdl.name=name;
                load_system(mdl.name);
                mdl.prevDirty=get_param(mdl.name,'Dirty');
                mdl.prevOpCountCollection=get_param(mdl.name,'OpCountCollection');
                mdl.prevConfigSet=getActiveConfigSet(mdl.name);
                if isa(mdl.prevConfigSet,'Simulink.ConfigSetRef')
                    mdl.newConfigSet=attachConfigSetCopy(mdl.name,mdl.prevConfigSet.getRefConfigSet,true);
                else
                    mdl.newConfigSet=attachConfigSetCopy(mdl.name,getActiveConfigSet(mdl.name),true);
                end
                setActiveConfigSet(mdl.name,mdl.newConfigSet.Name);
                obj.mdlMap(name)=mdl;
            end

            cfCleanup=onCleanup(@()restore_model(obj));

            for kk=keys(obj.mdlMap)
                mdl=obj.mdlMap(kk{1});
                set_param(mdl.name,'OpCountCollection','on');
                set_param(mdl.name,'SystemTargetFile','grt.tlc');
                set_param(mdl.name,'TargetLang','C');
                set_param(mdl.name,'ProdEqTarget','off');
                set_param(mdl.name,'TargetHWDeviceType','Custom Processor->MATLAB Host Computer');
                set_param(mdl.name,'MatFileLogging','on');
                set_param(mdl.name,'Solver','FixedStepAuto');
                set_param(mdl.name,'SolverMode','SingleTasking');
                set_param(mdl.name,'SaveFormat','StructureWithTime');
                set_param(mdl.name,'DefaultParameterBehavior','Tunable');
                set_param(mdl.name,'CustomInitializer','emlrtProfilingStart(); emlrtProfilingClear();');
                set_param(mdl.name,'CustomTerminator','emlrtProfilingSave(); emlrtProfilingFinish();');
                set_param(mdl.name,'CustomHeaderCode','#include "emlrt_profiling.h"');
                set_param(mdl.name,'PostCodeGenCommand','matlabshared.opcount.internal.supportfiles.updatebuildinfo(buildInfo)');
                set_param(mdl.name,'GenCodeOnly','off');
                set_param(mdl.name,'GenerateMakefile','on');
                set_param(mdl.name,'Toolchain','Automatically locate an installed toolchain');
                set_param(mdl.name,'GRTInterface','off');
                set_param(mdl.name,'CombineOutputUpdateFcns','on');
                set_param(mdl.name,'GenerateReport','off');
                set_param(mdl.name,'GenerateComments','on');
                set_param(mdl.name,'SimulinkBlockComments','on');
                set_param(mdl.name,'StateflowObjectComments','on');
                set_param(mdl.name,'MATLABSourceComments','on');
                set_param(mdl.name,'MaxIdLength','256');
                set_param(mdl.name,'RTWVerbose','off');
                if strcmp(obj.verbose,'on')
                    set_param(mdl.name,'RTWVerbose','on');
                end

            end

            featureCleanup=onCleanup(@()internal.cgir.Debug.disable);

            buildCleanup=onCleanup(@()cleanup_builddir(obj));



            cmd=['rtwbuild(''',obj.input_name,''')'];
            try
                s='';
                s=evalc(cmd);
            catch ME
                disp(s);
                rethrow(ME);
            end
            obj.nidb.writeNodeInfo;
            if strcmp(obj.verbose,'on')
                disp(s);
            end
        end

        function sl_execution(obj)

            if(ispc())
                exec_name=fullfile(obj.build_dir,[obj.input_name,'.exe']);
            else
                exec_name=fullfile(obj.build_dir,obj.input_name);
            end

            timeout=10;
            while~exist(exec_name,'file')
                if timeout<=0
                    error(message('shared_opcount:base:NoExec'));
                end
                pause(1);
                timeout=timeout-1;
            end


            origEnv=getenv('CGIR_PROFILING_DETAILED');
            envCleanup=onCleanup(@()setenv('CGIR_PROFILING_DETAILED',origEnv));
            setenv('CGIR_PROFILING_DETAILED','1')

            [status,results]=system(['"',exec_name,'"']);

            if status
                error(message('shared_opcount:base:BadExec',results));
            end

            timeout=10;
            while~exist(obj.nidb.Filename,'file')
                if timeout<=0
                    error(message('shared_opcount:base:NoDB'));
                end
                pause(1);
                timeout=timeout-1;
            end

            if exist(fullfile(obj.build_dir,[obj.input_name,'.mat']),'file')
                delete(fullfile(obj.build_dir,[obj.input_name,'.mat']));
            end
        end

        function data_collection(obj)
            if strcmp(obj.nidb.Mode,'STATIC')
                query='select * from (select RunId, SequenceId,case when instr(NodeName,'',#'') > 0 then substr(NodeName,0,instr(NodeName,'',#'')) else NodeName end as NodeName,FunctionName,Count,NodeExpr,NodeValue,TypeName from NodeCount) group by RunId, NodeName, NodeValue';
            else
                query='select distinct RunId, SequenceId,NodeName,FunctionName,Count,NodeExpr,NodeValue,TypeName from NodeCount';
            end

            cells=obj.db_query(query);

            if isempty(cells)
                return;
            end

            result={};

            j=1;
            for i=1:size(cells,1)
                path='';
                op='';
                link='';

                if any(strcmp(cells{i,6},{'call','multi_call'}))
                    op=['CALL(',cells{i,7},')'];
                else
                    op=[cells{i,7},'(',cells{i,6},')'];
                end

                switch op
                case{'CALL(plus)','CALL(sum)','CALL(Sum)'}
                    op='ADD(+)';
                case 'CALL(minus)'
                    op='MINUS(-)';
                case 'CALL(uminus)'
                    op='UMINUS(-u)';
                case{'CALL(times)','CALL(mtimes)','CALL(multiply)','CALL(eml_mtimes_helper)','MATRIX_MUL(mmul)'}
                    op='MUL(*)';
                case{'CALL(pow)','CALL(power)','CALL(mpower)'}
                    op='POW(^^)';
                case 'CALL(mrdivide)'
                    op='DIV(/)';
                case 'CALL(rdivide)'
                    op='DIV(/)';
                case 'CALL(rdivide_helper)'
                    op='DIV(/)';
                case 'CALL(mrdivide_helper)'
                    op='DIV(/)';
                case 'CALL(and)'
                    op='LOG_AND(&&)';
                case 'CALL(or)'
                    op='LOG_OR(||)';
                case 'CALL(ne)'
                    op='NE(!=)';
                case 'CALL(eq)'
                    op='EQ(==)';
                case 'CALL(ge)'
                    op='GE(>=)';
                case 'CALL(gt)'
                    op='GT(>)';
                case 'CALL(le)'
                    op='LE(<=)';
                case 'CALL(lt)'
                    op='LT(<)';
                case 'CALL(bitand)'
                    op='BIT_AND(&)';
                case 'CALL(bitor)'
                    op='BIT_OR(|)';
                case 'CALL(bitxor)'
                    op='BIT_XOR(^)';
                end

                if~isempty(obj.excl_op)
                    if~all(cellfun(@isempty,cellfun(@(x)regexp(op,['^',x,'$|^',x,'(?=\()|(?<=\()',x,'(?=\))']),obj.excl_op_regexp,'UniformOutput',false)))
                        continue;
                    end
                end

                if~isempty(obj.incl_op)
                    if all(cellfun(@isempty,cellfun(@(x)regexp(op,['^',x,'$|^',x,'(?=\()|(?<=\()',x,'(?=\))']),obj.incl_op_regexp,'UniformOutput',false)))
                        continue;
                    end
                end

                sid=cells{i,3};
                if~isempty(sid)
                    try
                        if obj.ismatlab
                            ismatlablink=true;
                            lm=coder.report.HTMLLinkManager;
                            loc=lm.getLinkToFrontEnd(sid);
                        end
                        if obj.issimulink
                            ismatlablink=false;
                            lm=Simulink.report.HTMLLinkManager;
                            lm.IncludeHyperlinkInReport=true;
                            loc=lm.getLinkToFrontEnd(sid);
                            if isempty(regexp(loc,'<a.*>(.*?)<\/a>','tokens'))
                                ismatlablink=true;
                                lm=coder.report.HTMLLinkManager;
                                loc=lm.getLinkToFrontEnd(sid);
                            else

                            end
                        end
                        if~isempty(loc)
                            loc=regexprep(loc,'name="[^"]*" \s*(class="[^"]*")','$1');
                            loc=regexprep(loc,',#(.*)\s*(<\/a>)','$2');
                            loc=strrep(loc,sprintf('\n'),' ');
                            if~isempty(loc)
                                link=loc;
                            end
                            fpath=regexp(loc,'<a.*>(.*?)<\/a>','tokens');
                            if~isempty(fpath)
                                path=fpath{1}{end};
                                if ismatlablink
                                    [file,~]=strtok(path,':');

                                    path=[file,'/',cells{i,4}];
                                end
                            end
                        else
                            continue;
                        end

                    catch
                        [path,~]=strtok(sid,':');
                        link='';
                    end
                end


                if~isempty(obj.incl_path)
                    if all(cellfun(@isempty,cellfun(@(x)regexp(path,['^',x,'$|^',x,'(?=\/)|(?<=\/)',x,'$|(?<=\/)',x,'(?=\/)']),obj.incl_path_regexp,'UniformOutput',false)))
                        continue;
                    end
                end

                if~isempty(obj.excl_path)
                    if~all(cellfun(@isempty,cellfun(@(x)regexp(path,['^',x,'$|^',x,'(?=\/)|(?<=\/)',x,'$|(?<=\/)',x,'(?=\/)']),obj.excl_path_regexp,'UniformOutput',false)))
                        continue;
                    end
                end

                opcnt=cells{i,5};
                optype=cells{i,8};

                optype=strrep(optype,'dynamic matrix','variable-size matrix');

                result{j,1}=path;
                result{j,2}=opcnt;
                result{j,3}=op;
                result{j,4}=optype;
                result{j,5}=link;
                j=j+1;
            end

            obj.result_data=result;
        end

        function[status,OperatorDetailedReport]=detailed_report(obj)

            OperatorDetailedReport=table;
            status=false;
            if isempty(obj.result_data)
                return;
            end

            OperatorDetailedReport=cell2table(obj.result_data,'VariableNames',{...
            'Path','Count','Operator','DataType','Link'});
            OperatorDetailedReport=sortrows(OperatorDetailedReport,{'Path','Count','Operator','DataType'},{'ascend','descend','ascend','ascend'});
            save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'OperatorDetailedReport','-append');
            writetable(OperatorDetailedReport,fullfile(obj.build_dir,[obj.input_name,'.xlsx']),'Sheet','OperatorDetailedReport');
            status=true;
        end

        function[status,OperatorAggregatedReport]=operator_aggregated_report(obj)

            OperatorAggregatedReport=table;
            status=false;
            if isempty(obj.result_data)
                return;
            end

            cells=[obj.result_data(:,2),obj.result_data(:,3),obj.result_data(:,4)];
            cells=sortrows(cells,[2,3]);

            aggregate={};

            for i=1:size(cells,1)
                idxs=0;
                idx=0;
                if~isempty(aggregate)
                    idxs=strcmp(cells(i,2),aggregate(:,2));
                end
                if any(idxs)
                    idxs=find(idxs);
                    for j=1:numel(idxs)
                        if strcmp(cells(i,3),aggregate(idxs(j),3))
                            idx=idxs(j);
                            break;
                        end
                    end
                end

                if idx
                    aggregate{idx,1}=aggregate{idx,1}+cells{i,1};
                else
                    aggregate=[aggregate;cells(i,:)];
                end
            end

            if~isempty(obj.incl_op)
                for k=1:numel(obj.incl_op)
                    if all(cellfun(@isempty,cellfun(@(x)regexp(x,['^',obj.incl_op_regexp{k},'$|^',obj.incl_op_regexp{k},'(?=\()|(?<=\()',obj.incl_op_regexp{k},'(?=\))']),aggregate(:,2),'UniformOutput',false)))
                        if~strcmp(obj.verbose,'quiet')
                            msg=message('shared_opcount:base:OperatorNotFound',obj.incl_op{k});
                            disp(msg.getString);
                        end
                    end
                end
            end

            OperatorAggregatedReport=cell2table(aggregate,'VariableNames',{'Count','Operator','DataType'});
            OperatorAggregatedReport=sortrows(OperatorAggregatedReport,{'Count','Operator','DataType'},{'descend','ascend','ascend'});
            save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'OperatorAggregatedReport','-append');
            writetable(OperatorAggregatedReport,fullfile(obj.build_dir,[obj.input_name,'.xlsx']),'Sheet','OperatorAggregatedReport');
            status=true;
        end

        function[status,PathAggregatedReport]=path_aggregated_report(obj)

            PathAggregatedReport=table;
            status=false;
            if isempty(obj.result_data)
                return;
            end

            cells=[obj.result_data(:,2),obj.result_data(:,1),obj.result_data(:,5)];
            cells=sortrows(cells,2);

            aggregate={};

            for i=1:size(cells,1)
                idxs=0;
                idx=0;
                if~isempty(aggregate)
                    idxs=strcmp(cells(i,2),aggregate(:,2));
                end
                if any(idxs)
                    idx=find(idxs);
                end

                if idx
                    aggregate{idx,1}=aggregate{idx,1}+cells{i,1};
                else
                    aggregate=[aggregate;cells(i,:)];
                end
            end

            if~isempty(obj.incl_path)
                for k=1:numel(obj.incl_path)
                    if all(cellfun(@isempty,cellfun(@(x)regexp(x,['^',obj.incl_path_regexp{k},'$|^',obj.incl_path_regexp{k},'(?=\/)|(?<=\/)',obj.incl_path_regexp{k},'$|(?<=\/)',obj.incl_path_regexp{k},'(?=\/)']),aggregate(:,2),'UniformOutput',false)))
                        if~strcmp(obj.verbose,'quiet')
                            msg=message('shared_opcount:base:PathNotFound',obj.incl_path{k});
                            disp(msg.getString);
                        end
                    end
                end
            end

            PathAggregatedReport=cell2table(aggregate,'VariableNames',{'Count','Path','Link'});
            PathAggregatedReport=sortrows(PathAggregatedReport,{'Count','Path','Link'},{'descend','ascend','ascend'});
            save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'PathAggregatedReport','-append');
            writetable(PathAggregatedReport,fullfile(obj.build_dir,[obj.input_name,'.xlsx']),'Sheet','PathAggregatedReport');
            status=true;
        end

        function[status,OperatorHierarchicalReport]=operator_hierarchical_report(obj)

            OperatorHierarchicalReport=table;
            status=false;
            if isempty(obj.result_data)
                return;
            end


            entrytbl=table(obj.result_data(:,3),obj.result_data(:,4),obj.result_data(:,2),cell(size(obj.result_data,1),1),cell(size(obj.result_data,1),1),obj.result_data(:,5),...
            'VariableNames',{'Operator','DataType','Count','FileName','Path','Link'});

            for i=1:size(entrytbl,1)
                if~isempty(entrytbl.Path(i))
                    spath=split(obj.result_data(i,1),'/');
                    entrytbl.FileName(i)=spath(1);
                    entrytbl.Path(i)=join(spath(2:end),'/');
                end
            end
            entrytbl=sortrows(entrytbl,{'Operator','DataType','Count','FileName','Path'},{'ascend','ascend','descend','ascend','ascend'});

            OperatorHierarchicalReport=matlabshared.opcount.internal.subtable.create_htable(entrytbl,{'Operator','DataType','Count','FileName','Path'});

            save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'OperatorHierarchicalReport','-append');
            status=true;

        end

        function[status,PathHierarchicalReport]=path_hierarchical_report(obj)

            PathHierarchicalReport=table;
            status=false;
            if isempty(obj.result_data)
                return;
            end


            entrytbl=table(cell(size(obj.result_data,1),1),cell(size(obj.result_data,1),1),obj.result_data(:,2),obj.result_data(:,3),obj.result_data(:,4),obj.result_data(:,5),...
            'VariableNames',{'FileName','Path','Count','Operator','DataType','Link'});
            for i=1:size(entrytbl,1)
                if~isempty(entrytbl.Path(i))
                    spath=split(obj.result_data(i,1),'/');
                    entrytbl.FileName(i)=spath(1);
                    entrytbl.Path(i)=join(spath(2:end),'/');
                end
            end
            entrytbl=sortrows(entrytbl,{'FileName','Path','Count','Operator','DataType'},{'ascend','ascend','descend','ascend','ascend'});

            PathHierarchicalReport=matlabshared.opcount.internal.subtable.create_htable(entrytbl,{'FileName','Path','Count','Operator','DataType'});

            save(fullfile(obj.build_dir,[obj.input_name,'.mat']),'PathHierarchicalReport','-append');
            status=true;

        end

        function db_open(obj,dbname)
            obj.db_connect=matlab.depfun.internal.database.SqlDbConnector;
            obj.db_connect.connect(dbname);
        end


        function cells=db_query(obj,query)

            obj.db_connect.doSql(query);
            data=obj.db_connect.fetchRows;

            if isempty(data)
                cells=[];
                return
            end
            rows=size(data,2);
            cols=size(data{1},2);
            cells=reshape([data{:}],cols,rows)';
        end

        function copy_output(obj)
            obj.db_connect.disconnect();

            if exist(obj.nidb.Filename,'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:CreatingFile',fullfile(obj.output_dir,[obj.input_name,'.db']));
                    disp(msg.getString);
                end
                movefile(obj.nidb.Filename,fullfile(obj.output_dir,[obj.input_name,'.db']));
            end
            if exist(fullfile(obj.build_dir,[obj.input_name,'.mat']),'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:CreatingFile',fullfile(obj.output_dir,[obj.input_name,'.mat']));
                    disp(msg.getString);
                end
                movefile(fullfile(obj.build_dir,[obj.input_name,'.mat']),fullfile(obj.output_dir,[obj.input_name,'.mat']));
            end

            if exist(fullfile(obj.build_dir,[obj.input_name,'.xlsx']),'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:CreatingFile',fullfile(obj.output_dir,[obj.input_name,'.xlsx']));
                    disp(msg.getString);
                end
                movefile(fullfile(obj.build_dir,[obj.input_name,'.xlsx']),fullfile(obj.output_dir,[obj.input_name,'.xlsx']));
            end
        end

        function setup_outputdir(obj)

            if strcmp(obj.verbose,'on')
                msg=message('shared_opcount:base:SetupOutputDir',obj.output_dir);
                disp(msg.getString);
            end

            [status,msg,msgID]=mkdir(obj.output_dir);
            if~status
                error(msgID,msg);
            end
            if strcmp(obj.verbose,'on')
                if~isempty(msg)
                    disp(msg);
                end
            end

            cd(obj.output_dir);
            obj.output_dir=pwd;

            if exist(fullfile(obj.output_dir,[obj.input_name,'.db']),'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:DeletingFile',fullfile(obj.output_dir,[obj.input_name,'.db']));
                    disp(msg.getString);
                end
                delete(fullfile(obj.output_dir,[obj.input_name,'.db']));
            end
            if exist(fullfile(obj.output_dir,[obj.input_name,'.mat']),'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:DeletingFile',fullfile(obj.output_dir,[obj.input_name,'.mat']));
                    disp(msg.getString);
                end
                delete(fullfile(obj.output_dir,[obj.input_name,'.mat']));
            end
            if exist(fullfile(obj.output_dir,[obj.input_name,'.xlsx']),'file')
                if strcmp(obj.verbose,'on')
                    msg=message('shared_opcount:base:DeletingFile',fullfile(obj.output_dir,[obj.input_name,'.xlsx']));
                    disp(msg.getString);
                end
                delete(fullfile(obj.output_dir,[obj.input_name,'.xlsx']));
            end
        end

        function setup_builddir(obj)

            if strcmp(obj.verbose,'on')
                msg=message('shared_opcount:base:SetupBuildDir',fullfile(obj.output_dir,'opcount_build'));
                disp(msg.getString);
            end

            if exist(fullfile(obj.output_dir,'opcount_build'),'dir')
                [~,~,~]=rmdir(fullfile(obj.output_dir,'opcount_build'),'s');
            end
            [status,msg,msgID]=mkdir(fullfile(obj.output_dir,'opcount_build'));
            if~status
                error(msgID,msg);
            end
            cd(fullfile(obj.output_dir,'opcount_build'));
            obj.build_dir=pwd;
        end

        function cleanup_builddir(obj)
            try
                rmdir(fullfile(obj.output_dir,'opcount_build','*'),'s');
            catch
            end
        end

        function restore_model(obj)

            for kk=keys(obj.mdlMap)
                mdl=obj.mdlMap(kk{1});
                setActiveConfigSet(mdl.name,mdl.prevConfigSet.Name);
                detachConfigSet(mdl.name,mdl.newConfigSet.Name);
                set_param(mdl.name,'OpCountCollection',mdl.prevOpCountCollection);
                set_param(mdl.name,'Dirty',mdl.prevDirty);
            end

        end

    end
end

