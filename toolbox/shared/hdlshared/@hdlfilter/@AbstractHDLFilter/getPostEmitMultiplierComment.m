function getPostEmitMultiplierComment(this)






    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        mult_comment=[];
        resrc=PersistentHDLResource;
        if~isempty(resrc)
            bom_keys=resrc(end).bom.keys;
            mult_keys=bom_keys(strncmp('mul_',bom_keys,4));
            mult_count=0;

            for key_index=1:length(mult_keys)
                mult_count=mult_count+resrc(end).bom(mult_keys{key_index});
            end

            if mult_count~=0

                commentchars=this.getHDLParameter('comment_char');
                mult_comment=[commentchars,' Multipliers           : ',...
                num2str(mult_count)];
            end
        end


        this.Comment=[this.Comment,mult_comment,char(10),char(10),char(10)];
    end
