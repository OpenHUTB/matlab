
























































function out=getYkgwHdrCoregist(filepath)

    function_revision=1;
    function_name='getYkgwHdrCoregist';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    key='tzsvq27h';

    NoMriFile=0;
    NormalMriFile=1;
    VirtualMriFile=2;

    UNKNOWN_MODEL=-1;
    NO_MODEL=0;
    SPHERICAL_MODEL=1;
    LAYERED_MODEL=2;
    ELLIPTIC_MODEL=3;
    MULTILAYER_SPHERICAL_MODEL=4;


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    mri_info=GetSqf(fid,key,'MrImage');
    matching_info=GetSqf(fid,key,'Matching');


    fclose(fid);

    if isempty(mri_info)||isempty(matching_info)
        disp(['ERROR ( ',function_name,' ): Reading error was occurred.']);
        return;
    end

    hpi_labels={'LPA','RPA','CPF','LPF','RPF','','',''};


    out.done=matching_info.done;
    out.mri_type=mri_info.mri_type;
    out.mri_file=mri_info.mri_file;
    out.hpi_file=matching_info.marker_file;
    out.meg2mri=matching_info.meg_to_mri;
    out.mri2meg=matching_info.mri_to_meg;
    for ii=1:size(matching_info.marker,2)
        if matching_info.marker(ii).meg_done
            out.hpi(ii).meg_pos=matching_info.marker(ii).meg_pos;
            out.hpi(ii).mri_pos=matching_info.marker(ii).mri_pos;
            out.hpi(ii).label=hpi_labels{ii};
        else
            if ii<=5
                out.hpi(ii).meg_pos=matching_info.marker(ii).meg_pos;
                out.hpi(ii).mri_pos=matching_info.marker(ii).mri_pos;
                out.hpi(ii).label=hpi_labels{ii};
            end
        end
    end
    switch mri_info.model.type
    case NO_MODEL
        out.model.type=NO_MODEL;
    case SPHERICAL_MODEL
        out.model.type=SPHERICAL_MODEL;
        out.model.cx=mri_info.model.cx;
        out.model.cy=mri_info.model.cy;
        out.model.cz=mri_info.model.cz;
        out.model.radius=mri_info.model.radius;
    case LAYERED_MODEL
        out.model.type=LAYERED_MODEL;
        out.model.ax=mri_info.model.ax;
        out.model.ay=mri_info.model.ay;
        out.model.az=mri_info.model.az;
        out.model.c=mri_info.model.c;
    otherwise
        out.model.type=UNKNOWN_MODEL;
    end

