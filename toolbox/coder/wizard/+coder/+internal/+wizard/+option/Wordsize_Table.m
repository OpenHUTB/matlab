


classdef Wordsize_Table<coder.internal.wizard.OptionBase
    properties


        Parameters={'ProdBitPerChar','ProdBitPerShort','ProdBitPerInt',...
        'ProdBitPerLong','ProdBitPerLongLong','ProdWordSize','ProdBitPerPointer','ProdBitPerSizeT','ProdBitPerPtrDiffT'};
        Prompts={'char:','short:','int:','long:','long long:','native:','pointer:','size_t:','ptrdiff_t:'};
    end
    methods
        function obj=Wordsize_Table(env)
            id='Wordsize_Table';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Optimization';
            obj.Type='group';
            obj.Value={};
            obj.HasHintMessage=false;
        end
        function onNext(~)

        end
        function setWordsizeTable(obj)
            env=obj.Env;
            q=env.getQuestionObj(obj.Question_Id);
            if q.isCustom
                readOnly=false;
            else
                readOnly=true;
            end
            num=length(obj.Parameters);
            g=cell(1,num);
            hwCC=obj.getHWCC;
            for i=1:num
                g{i}=struct('Name',obj.Prompts{i},'Type','text',...
                'Value',hwCC.get_param(obj.Parameters{i}),'Id',obj.Parameters{i},...
                'ReadOnly',readOnly);
            end
            obj.Value=struct('OptionId',obj.Id,'Items',{g},'ItemPerRow',3);
        end
        function status=applyChangeToHWCC(obj)
            status=true;
            env=obj.Env;
            hwCC=obj.getHWCC;
            if~isempty(obj.Env.LastAnswer)&&isa(obj.Env.LastAnswer.Value,'struct')
                o={obj.Env.LastAnswer.Value.option};
                for i=1:length(obj.Parameters)
                    idx=ismember(o,obj.Parameters{i});
                    if sum(idx)~=0
                        env.setParamRequired(obj.Parameters{i},obj.Env.LastAnswer.Value(idx).value);
                        value=obj.Env.LastAnswer.Value(idx).value;
                        if isscalar(value)
                            hwCC.set_param(obj.Parameters{i},value);
                        end
                    end
                end
            end
        end
        function applyChangeToChangeLog(obj)
            env=obj.Env;
            hwCC=obj.getHWCC;
            for i=1:length(obj.Parameters)
                env.CSM.setParamRequired(obj.Parameters{i},hwCC.get_param(obj.Parameters{i}));
            end
        end
        function out=getHWCC(obj)
            env=obj.Env;
            q=env.getQuestionObj(obj.Question_Id);
            out=q.getHWCC;
        end
    end
end
