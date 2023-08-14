classdef functionStubInfo<handle




    properties
        Name(1,1)string
        Signature(1,1)string
        Body(1,1)string
        extraGlobal(1,:)string
        extraGlobalDefinitions(1,:)string
        useMemCpy(1,1)logical
    end

    methods

        function definition=getDefinition(self)


            definition=self.Signature+newline+...
            "{"+newline+...
            self.Body+newline+...
            "}"+newline;
        end

    end

end
