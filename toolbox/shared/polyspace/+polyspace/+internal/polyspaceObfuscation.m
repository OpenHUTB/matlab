

classdef polyspaceObfuscation

    properties(Access=protected)
        encryptionKey='';
    end






    methods(Access=public)


        function self=polyspaceObfuscation(key)
            self.encryptionKey=unicode2native(key,'UTF-8');
        end



        function dst=encrypt(self,src)
            src=unicode2native(src,'UTF-8');
            dst=polyspace_obfuscation_mex(src,self.encryptionKey);
            dst=sprintf('%02x',dst);
        end



        function dst=decrypt(self,src)
            src=transpose(uint8(sscanf(src,'%02x')));
            dst=polyspace_obfuscation_mex(src,self.encryptionKey);
            dst=native2unicode(dst,'UTF-8');
        end
    end

end

