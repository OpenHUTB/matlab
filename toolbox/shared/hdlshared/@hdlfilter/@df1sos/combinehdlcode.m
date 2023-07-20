function hdlarch=combinehdlcode(this,hdlarch,varargin)







    fields=fieldnames(hdlarch);
    for n=1:nargin-2
        codesnippet=varargin(n);
        codesnippet=codesnippet{:};
        for fd=1:length(fields)
            field=fields{fd};
            if isfield(codesnippet,field)
                hdlarch.(field)=[hdlarch.(field),codesnippet.(field)];
            end
        end
    end



