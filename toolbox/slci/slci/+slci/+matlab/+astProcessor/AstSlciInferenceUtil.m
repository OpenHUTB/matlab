




classdef AstSlciInferenceUtil

    methods(Static=true)

        function[success,value]=evalValue(ast)

            success=false;
            value=0;


            if ast.hasMtree()&&...
                slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(ast)
                mtNode=ast.getMtree();
                str=mtNode.tree2str();
                [success,value]=slci.matlab.astProcessor.AstSlciInferenceUtil.evalStr(str);
                if~success
                    [success,value]=...
                    slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(ast);
                end
            end
        end


        function[success,dataType]=evalDataType(ast)


            dataType='';


            [success,val]=slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(ast);
            if success
                typeStr=class(val);
                if strcmp(typeStr,'logical')%#ok
                    typeStr='boolean';
                end
                dataType=typeStr;
            end
        end


        function[success,dim]=evalDim(ast)


            dim=-1;


            [success,val]=slci.matlab.astProcessor.AstSlciInferenceUtil.evalValue(ast);
            if success
                dim=size(val);
            end
        end



        function flag=isConstant(ast)

            flag=false;

            switch class(ast)

            case 'slci.ast.SFAstString'


                flag=true;

            case{'slci.ast.SFAstNum',...
                'slci.ast.SFAstIntegerNum',...
                'slci.ast.SFAstFloatNum'}


                flag=true;

            case{'slci.ast.SFAstUminus',...
                'slci.ast.SFAstUplus'}


                ch=ast.getChildren();
                for k=1:numel(ch)
                    if~slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(ch{k})
                        flag=false;
                        return;
                    end
                end
                flag=true;

            case{'slci.ast.SFAstConcatenateLB',...
                'slci.ast.SFAstRow',...
                'slci.ast.SFAstColon'}


                ch=ast.getChildren();

                if isempty(ch)
                    flag=true;
                    return;
                end
                for k=1:numel(ch)
                    if~slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(ch{k})
                        flag=false;
                        return;
                    end
                end
                flag=true;

            case{'slci.ast.SFAstZeros'...
                ,'slci.ast.SFAstOnes'...
                ,'slci.ast.SFAstEye'}


                ch=ast.getChildren();
                for k=1:numel(ch)
                    if~slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(ch{k})
                        flag=false;
                        return;
                    end
                end
                flag=true;

            case{'slci.ast.SFAstDirectCast'...
                ,'slci.ast.SFAstCastFunction'...
                ,'slci.ast.SFAstExplicitTypeCast'}
                ch=ast.getChildren();
                assert(numel(ch)>0);
                flag=slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(ch{1});

            case{'slci.ast.SFAstLength'...
                ,'slci.ast.SFAstNumel'}
                ch=ast.getChildren();
                assert(numel(ch)==1);
                dim=ch{1}.getDataDim;
                if~isequal(dim,-1)

                    flag=true;
                end

            case 'slci.ast.SFAstIdentifier'
                flag=slci.matlab.astProcessor.AstSlciInferenceUtil.isConstVar(...
                ast.getIdentifier,ast.ParentBlock);

            otherwise
                if ast.hasMtree()
                    mtNode=ast.getMtree();
                    str=mtNode.tree2str();
                    [flag,~]=...
                    slci.matlab.astProcessor.AstSlciInferenceUtil.evalStr(str);
                end
            end
        end

        function[success,val]=getValue(ast)
            success=false;
            val=0;
            switch class(ast)
            case 'slci.ast.SFAstExplicitTypeCast'
                children=ast.getChildren();
                [success,val]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(children{1});
            case 'slci.ast.SFAstUminus'
                children=ast.getChildren();
                [success,value]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(children{1});
                if success
                    val=-value;
                end
            case 'slci.ast.SFAstUplus'
                children=ast.getChildren();
                [success,value]=...
                slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(children{1});
                if success
                    val=value;
                end
            case{'slci.ast.SFAstNum',...
                'slci.ast.SFAstIntegerNum',...
                'slci.ast.SFAstFloatNum'}
                success=true;
                val=ast.getValue();
            case 'slci.ast.SFAstLength'
                success=true;
                ch=ast.getChildren();
                assert(numel(ch)==1);
                dim=ch{1}.getDataDim;
                assert(~isequal(dim,-1));
                val=max(dim);
            case 'slci.ast.SFAstNumel'
                success=true;
                ch=ast.getChildren();
                assert(numel(ch)==1);
                dim=ch{1}.getDataDim;
                assert(~isequal(dim,-1));
                [flag,dim]=slci.internal.resolveDim(ast.ParentModel.getHandle,dim);
                if~flag
                    return;
                end
                val=prod(dim);
            case 'slci.ast.SFAstColon'
                ch=ast.getChildren();
                if numel(ch)>1
                    [success,value]=...
                    slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(ch{1});
                    if success
                        str=num2str(value);
                        for i=2:numel(ch)
                            str=[str,':'];%#ok
                            [success,value]=...
                            slci.matlab.astProcessor.AstSlciInferenceUtil.getValue(ch{i});
                            if success
                                str=[str,num2str(value)];%#ok
                            else
                                return;
                            end
                        end
                        [success,val]=...
                        slci.matlab.astProcessor.AstSlciInferenceUtil.evalStr(str);
                    end
                end

            case 'slci.ast.SFAstIdentifier'
                try
                    value=slResolve(ast.getIdentifier,ast.ParentBlock.getHandle);
                    if isnumeric(value)
                        success=true;
                        val=value;
                    end
                catch
                end

            otherwise
                if ast.hasMtree()
                    mtNode=ast.getMtree();
                    str=mtNode.tree2str();
                    [success,val]=...
                    slci.matlab.astProcessor.AstSlciInferenceUtil.evalStr(str);
                end
            end

        end


        function[flag,val]=evalStr(str)
            try
                val=evalin('caller',str);
                flag=true;
            catch
                flag=false;
                val=[];
            end
        end

        function out=isConstVar(id,block)
            out=false;

            value=[];
            try

                mdlWks=get_param(block.ParentModel.getName,'ModelWorkspace');
                value=evalin(mdlWks,id);
            catch
            end

            if isempty(value)
                try

                    value=evalin('base',id);
                catch
                end
            end

            if isnumeric(value)
                out=true;
                return;
            end

            if isa(value,'Simulink.Parameter')...
                &&strcmp(get_param(block.ParentModel.getHandle,'DefaultParameterBehavior'),'Inlined')
                sc=value.CoderInfo.StorageClass;
                out=(strcmp(sc,'Auto')...
                ||(strcmp(sc,'Custom')&&strcmp(value.CoderInfo.CustomStorageClass,'ImportedDefine')));
            end

        end

    end

end
