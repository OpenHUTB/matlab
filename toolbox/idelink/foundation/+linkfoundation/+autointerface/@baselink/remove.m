function remove(h,varargin)










































    narginchk(2,nargin);
    linkfoundation.util.errorIfArray(h);


    inputFormat=GetInputFormat(varargin,nargin);

    if strcmpi(inputFormat,'REMOVE-FILE-FROM-PROJECT')
        filename=varargin{1};
        if~ischar(filename),
            error(message('ERRORHANDLER:autointerface:InvalidNonCharFilename'));
        elseif isempty(filename),
            error(message('ERRORHANDLER:autointerface:InvalidEmptyFilename'));
        end
        h.mIdeModule.RemoveFileFromProject(filename);
    else
        h.removebrkpt(inputFormat,varargin{:});
    end


    function inputFormat=GetInputFormat(args,nargs)
        if(nargs>=3)&&isnumeric(args{2}),
            inputFormat='FILE-LINE';
        elseif ischar(args{1})&&strcmpi(args{1},'all'),
            inputFormat='ALL';
        elseif isnumeric(args{1}),
            inputFormat='ADDRESS';
        elseif ischar(args{1}),

            [fpath,fname,fext]=fileparts(args{1});
            if isempty(fext)
                inputFormat='ADDRESS';
            else
                inputFormat='REMOVE-FILE-FROM-PROJECT';
            end
        else
            inputFormat='';
        end


