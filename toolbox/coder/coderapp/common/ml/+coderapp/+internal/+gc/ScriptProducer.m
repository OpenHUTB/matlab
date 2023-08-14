classdef(Hidden,Sealed)ScriptProducer<coderapp.internal.config.AbstractProducer


    properties(Constant,Hidden)
        SNAPSHOT_PATH=fullfile(matlabroot,'toolbox/coder/coderapp/common/schemas/globalconfig_snapshot.json')
    end

    methods
        function produce(this)
            contribKeys=this.keys();
            contribKeys(~this.isUserModified(contribKeys))=[];
            script=coderapp.internal.script.ScriptBuilder();
            if isempty(contribKeys)
                this.ScriptModel=script;
                return
            end

            contribVals=this.getScriptValues(contribKeys);
            script=script.appendf('coderapp.internal.globalconfig(');
            multiline=~isscalar(contribKeys);
            if multiline
                script=script.appendf(' ...\n');
            end

            for i=1:numel(contribKeys)
                if multiline
                    script=script.appendf('    ');
                end
                pvPair=coderapp.internal.script.ScriptBuilder().annotate('param',contribKeys{i});
                pvPair=pvPair.appendf('"%s", ',contribKeys{i}).append(contribVals{i});
                script=script.append(pvPair);
                if i~=numel(contribKeys)
                    script=script.appendf(', ...\n');
                end
            end
            script=script.append(');');
            this.ScriptModel=script;
        end
    end
end