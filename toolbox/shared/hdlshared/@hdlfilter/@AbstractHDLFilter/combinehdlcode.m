function hdlarch=combinehdlcode(this,hdlarch,varargin)










    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        fields=fieldnames(hdlarch);
        for n=1:nargin-2
            codesnippet=varargin(n);
            codesnippet=codesnippet{:};
            if isstruct(codesnippet)
                codesnippet=l_harmonisehdlstruct(this,codesnippet);
                for fd=1:length(fields)
                    field=fields{fd};
                    if isfield(codesnippet,field)
                        hdlarch.(field)=[hdlarch.(field),codesnippet.(field)];
                    end
                end
            end
        end
    end


    function newcodestruct=l_harmonisehdlstruct(this,codestruct)




        if l_isStructFDHCStyle(this,codestruct)
            newcodestruct=codestruct;
        else
            hdlfieldnames=fieldnames(codestruct);

            tmpcodestruct=emit_inithdlarch(this);


            for n=1:numel(hdlfieldnames)
                hdlfname=hdlfieldnames{n};


                matchingfdhcfieldname=strrep(hdlfname,'arch_','');
                if isfield(tmpcodestruct,matchingfdhcfieldname)
                    newcodestruct.(matchingfdhcfieldname)=codestruct.(hdlfname);
                elseif any(strfind(hdlfname,'entity_'))

                else
                    error(message('HDLShared:hdlfilter:wrongfield'));
                end
            end
        end

        function success=l_isStructFDHCStyle(this,codestruct)

            tmpcodestruct=emit_inithdlarch(this);

            fdhcstylefieldnames=fieldnames(tmpcodestruct);
            success=false;
            for n=1:numel(fdhcstylefieldnames)
                success=success||isfield(codestruct,fdhcstylefieldnames{n});
            end
