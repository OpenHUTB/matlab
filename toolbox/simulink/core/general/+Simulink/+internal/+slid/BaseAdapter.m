classdef(Abstract)BaseAdapter<matlab.mixin.Heterogeneous




    methods(Static=true,Abstract=true)


        extensions=getSupportedExtensions();







        entities=getSupportedEntityClasses();











        [readable,diagnostic]=isReadable(source,diagnostic);































        [writable,diagnostic]=isWritable(source,diagnostic);

































        [discoveredEntityInfoArray,diagnostic]=find(source,entityClasses,diagnostic);







































        [modelElement,diagnostic]=read(source,id,diagnostic);


































        diagnostic=update(source,id,modelElement,diagnostic);




































        checksum=getCheckSum(source);











        references=getExternalSources(source);












    end


    methods(Static=true)
        function[id,diagnostic]=create(source,modelElement,diagnostic)%#ok<*INUSL>
            id='';
        end

        function diagnostic=discard(source,id,diagnostic)
        end
    end

end
