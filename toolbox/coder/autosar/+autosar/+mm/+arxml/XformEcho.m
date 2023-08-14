



classdef XformEcho<handle
    properties(Access=public)
AutosarTargetNsUri
AutosarSourceNsUri
Transformer

Stack
State
Indent
Ser
    end

    methods
        function self=XformEcho(versionStr,transformer)
            self.AutosarSourceNsUri=autosar.mm.arxml.SchemaUtil.getSchemaUri(versionStr);
            self.AutosarTargetNsUri=autosar.mm.arxml.SchemaUtil.getSchemaUri(versionStr);
            self.Transformer=transformer;
            self.registerDefaultContext(@self.printContext);

            self.Stack={};
            self.State=0;
            self.Indent=0;
            self.Ser=-1;
        end

        function delete(self)
            self.Transformer=[];
        end

        function retSeq=printContext(self,context)
            retSeq=M3I.ContextSequence;
            retSeq.addContext(context);

            if self.Ser~=self.Transformer.SerializePhase
                self.Ser=self.Transformer.SerializePhase;
                fprintf(1,'***** SerializePhase=%d *****',self.Ser);
            end

            needIndent=0;

            if(self.State==1||self.State==2)&&context.Element
                fprintf(1,'>');
            end

            if self.State==0

                needIndent=1;
            elseif self.State==1&&(context.Element||context.EndElement)

                fprintf(1,'\n');
                needIndent=1;
            end

            if context.EndElement&&~context.ValueElement
                self.Indent=self.Indent-2;
            end

            if needIndent
                self.doIndent;
            end

            if context.Skip
                fprintf(1,'[SKIP]');
            elseif context.IsEmpty
                fprintf(1,'[]');
            elseif context.Attribute
                fprintf(1,' %s="%s"',context.RoleName,context.getValue);
            elseif context.EndElement&&context.ValueElement
                self.leaveElement(context);
                fprintf(1,'%s</%s>\n',context.getValue,context.RoleName);
                self.State=0;
            elseif context.EndElement
                self.leaveElement(context);
                fprintf(1,'</%s>\n',context.RoleName);
                self.State=0;
            elseif context.Element
                self.enterElement(context);
                fprintf(1,'<%s',context.RoleName);
                if~context.ValueElement
                    self.State=1;
                    self.Indent=self.Indent+2;
                else
                    self.State=2;
                end
            elseif context.Comment
                fprintf(1,'<!--%s-->\n',context.getValue);
            else





                fprintf(1,'<>');
            end
        end

        function enterElement(self,context)
            if self.State==2
                fprintf(1,'{*** BAD: element nested in value element ***}');
            end
            self.Stack{end+1}=context.RoleName;
        end

        function leaveElement(self,context)
            if isempty(self.Stack)
                fprintf(1,'{*** BAD: end element without start element ***}');
            elseif~strcmp(self.Stack{end},context.RoleName)
                fprintf(1,'{*** BAD: end element does not match ''%s'' ***}',self.Stack{end});
            end

            if~isempty(self.Stack)
                self.Stack=self.Stack(1:end-1);
            end
        end

        function doIndent(self)
            fprintf(1,'%*.*s',self.Indent,self.Indent,'');
        end

        function registerDefaultContext(self,func)
            context=M3I.Context;
            self.Transformer.addPreTransform(context,func);
            self.Transformer.addPostTransform(context,func);
        end
    end
end


