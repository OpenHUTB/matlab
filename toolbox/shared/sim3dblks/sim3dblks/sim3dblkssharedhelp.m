function sim3dblkssharedhelp(fileStr)







    narginchk(0,1);

    if nargin<1

        doc_tag=getblock_help_file(gcb);
    else

        doc_tag=getblock_help_file(gcb,fileStr);
    end

    docType=sim3dblkssharedtest(gcb);
    switch docType
    case '0'
        mapfile_location=fullfile(docroot,'aeroblks','helptargets.map');
    case '2'
        mapfile_location=fullfile(docroot,'vdynblks','helptargets.map');
    case '3'
        mapfile_location=fullfile(docroot,'driving','helptargets.map');
    case '4'
        mapfile_location=fullfile(docroot,'uav','helptargets.map');
    case '5'
        mapfile_location=fullfile(docroot,'sl3d','sl3d.map');
    otherwise
        mapfile_location=fullfile(docroot,'vdynblks','helptargets.map');
    end

    helpview(mapfile_location,doc_tag);
end

function help_file=getblock_help_file(blk,varargin)
    if nargin>1
        fileStr=varargin{1};
    else


        fileStr=get_param(blk,'MaskType');
    end
























    help_file=help_name(fileStr);
end

function filename=help_name(x)







    if isempty(x)
        x='default';
    end

    filename=lower(x);

    filename(isspace(filename))='_';
    dash_idx=(filename=='-');
    filename(dash_idx)='_';

    digit_idx=(filename>='0'&filename<='9');
    underscore_idx=(filename=='_');
    period_idx=(filename=='.');

    valid_char_idx=isletter(filename)|digit_idx|underscore_idx|period_idx;

    filename=filename(valid_char_idx);
end