








































































function out=getYkgwMriHdr(filepath)

    function_revision=3;
    function_name='getYkgwMriHdr';




    out=[];


    if nargin~=1
        disp(['ERROR ( ',function_name,' ): Arguments is illegal !!']);
        return;
    end


    fid=fopen(filepath,'rb','ieee-le');
    if fid==-1
        disp('ERROR: File can not be opened!');
        return;
    end


    file_name=deblank(fopen(fid));
    len_f=length(file_name);
    name_f=file_name(len_f-2:len_f);
    if~strcmp(name_f,'mri')
        disp(['ERROR ( ',function_name,' ): This file is not .mri file!!']);
        fclose(fid);
        return;
    end


    MaxMarkerCount=8;
    MaxNormalizeParameterCount=3;
    MaxBesaFiducialPointCount=5;
    NO_MODEL=0;
    SPHERICAL_MODEL=1;
    LAYERED_MODEL=2;
    ELLIPTIC_MODEL=3;
    MULTILAYER_SPHERICAL_MODEL=4;
    NormalizeParameternameLength=16;
    NoNormalizeType=hex2dec('0');


    fseek(fid,0,'bof');




    data_style=fread(fid,1,'int32');








    model_done=fread(fid,1,'int32');
    model_type=fread(fid,1,'int32');
    cx=fread(fid,1,'double');
    cy=fread(fid,1,'double');
    cz=fread(fid,1,'double');
    r=fread(fid,1,'double');

    model.done=model_done;
    switch model_type
    case SPHERICAL_MODEL
        model.type=model_type;
        model.cx=cx;
        model.cy=cy;
        model.cz=cz;
        model.radius=r;
    case LAYERED_MODEL
        model.type=model_type;
        model.ax=cx;
        model.ay=cy;
        model.az=cz;
        model.c=r;
    otherwise
        model.type=model_type;
    end


    hpi_labels={'LPA','RPA','CPF','LPF','RPF','','',''};
    marker_done=fread(fid,1,'int32');
    marker_count=fread(fid,1,'int32');
    for cnt=1:MaxMarkerCount
        mri_type=fread(fid,1,'int32');
        meg_type=fread(fid,1,'int32');
        pos(cnt).done=fread(fid,1,'int32');
        meg_done=fread(fid,1,'int32');
        pos(cnt).x=fread(fid,1,'double');
        pos(cnt).y=fread(fid,1,'double');
        pos(cnt).z=fread(fid,1,'double');
        mx_meg=fread(fid,1,'double');
        my_meg=fread(fid,1,'double');
        mz_meg=fread(fid,1,'double');
    end

    if marker_count>5
        marker_count=5;
    end
    marker=[];
    for ii=1:marker_count
        if marker_done
            marker(ii).done=pos(ii).done;
            marker(ii).mri_pos=[pos(ii).x,pos(ii).y,pos(ii).z];
            marker(ii).label=hpi_labels{ii};
        else
            if ii<=5
                marker(ii).done=0;
                marker(ii).mri_pos=[];
                marker(ii).label=hpi_labels{ii};
            end
        end
    end


























    min_img=fread(fid,1,'int16');
    max_img=fread(fid,1,'int16');
    image_parameter.intensity=[min_img,max_img];
    min_img=fread(fid,1,'int16');
    max_img=fread(fid,1,'int16');
    image_parameter.initial_color=[min_img,max_img];
    min_img=fread(fid,1,'int16');
    max_img=fread(fid,1,'int16');
    image_parameter.color=[min_img,max_img];


    normalize_enable=fread(fid,1,'int32');
    normalize_done=fread(fid,1,'int32');
    mri_to_normalize=fread(fid,[4,4],'double');mri_to_normalize=mri_to_normalize';
    normalize_type=fread(fid,1,'int32');
    name=GetNormalizeParameterName(normalize_type);
    for cnt=1:MaxNormalizeParameterCount
        tmp=fread(fid,NormalizeParameternameLength,'uchar');
        index=min(find(tmp==0));
        ndata(cnt).name=name{cnt};
        ndata(cnt).done=fread(fid,1,'int32');
        ndata(cnt).x=fread(fid,1,'double');
        ndata(cnt).y=fread(fid,1,'double');
        ndata(cnt).z=fread(fid,1,'double');
    end



























    if(normalize_type~=NoNormalizeType)&&normalize_done
        if(mri_to_normalize(1,1)>=0.5)&&(abs(mri_to_normalize(2,2))>=0.5)&&(abs(mri_to_normalize(1,2))<0.5)&&(abs(mri_to_normalize(2,1))<0.5)

            mri_to_normalize(1,:)=-mri_to_normalize(1,:);
            mri_to_normalize(2,:)=-mri_to_normalize(2,:);
        end
    end

    if~normalize_done
        mri_to_normalize=zeros(4,4);
        for cnt=1:MaxNormalizeParameterCount
            ndata(cnt).name='';
            ndata(cnt).done=0;
            ndata(cnt).x=[];
            ndata(cnt).y=[];
            ndata(cnt).z=[];
        end
    end

    normalize.done=normalize_done;
    normalize.mri2normalize=mri_to_normalize;
    normalize.point=ndata;


    for cnt=1:MaxBesaFiducialPointCount
        besa_done=fread(fid,1,'int32');
        besa_x=fread(fid,1,'double');
        besa_y=fread(fid,1,'double');
        besa_z=fread(fid,1,'double');
        if besa_done==true
            besa_fiducial_point(cnt).done=besa_done;
            besa_fiducial_point(cnt).x=besa_x;
            besa_fiducial_point(cnt).y=besa_y;
            besa_fiducial_point(cnt).z=besa_z;
        else
            besa_fiducial_point(cnt).done=besa_done;
            besa_fiducial_point(cnt).x=[];
            besa_fiducial_point(cnt).y=[];
            besa_fiducial_point(cnt).z=[];
        end
    end


    fseek(fid,0,'bof');


    fclose(fid);


    out.data_style=data_style;
    out.model=model;
    out.hpi=marker;
    out.image_parameter=image_parameter;
    out.normalize=normalize;
    out.besa_fiducial.point=besa_fiducial_point;





    function name=GetNormalizeParameterName(type)

        NoNormalizeType=hex2dec('0');
        NormalizeByXpXmYpType=hex2dec('1');
        NormalizeByXpXmYmType=hex2dec('2');
        NormalizeByXpXmZpType=hex2dec('3');
        NormalizeByXpXmZmType=hex2dec('4');
        NormalizeByYmYpXpType=hex2dec('5');
        NormalizeByYmYpXmType=hex2dec('6');
        NormalizeByYmYpZpType=hex2dec('7');
        NormalizeByYmYpZmType=hex2dec('8');
        NormalizeByZpZmXpType=hex2dec('9');
        NormalizeByZpZmXmType=hex2dec('10');
        NormalizeByZpZmYpType=hex2dec('11');
        NormalizeByZpZmYmType=hex2dec('12');

        NormalizePerpendicType=hex2dec('100');
        NormalizeByXpXmYpPerpendicType=bitor(NormalizePerpendicType,NormalizeByXpXmYpType);
        NormalizeByXpXmYmPerpendicType=bitor(NormalizePerpendicType,NormalizeByXpXmYmType);
        NormalizeByXpXmZpPerpendicType=bitor(NormalizePerpendicType,NormalizeByXpXmZpType);
        NormalizeByXpXmZmPerpendicType=bitor(NormalizePerpendicType,NormalizeByXpXmZmType);
        NormalizeByYmYpXpPerpendicType=bitor(NormalizePerpendicType,NormalizeByYmYpXpType);
        NormalizeByYmYpXmPerpendicType=bitor(NormalizePerpendicType,NormalizeByYmYpXmType);
        NormalizeByYmYpZpPerpendicType=bitor(NormalizePerpendicType,NormalizeByYmYpZpType);
        NormalizeByYmYpZmPerpendicType=bitor(NormalizePerpendicType,NormalizeByYmYpZmType);
        NormalizeByZpZmXpPerpendicType=bitor(NormalizePerpendicType,NormalizeByZpZmXpType);
        NormalizeByZpZmXmPerpendicType=bitor(NormalizePerpendicType,NormalizeByZpZmXmType);
        NormalizeByZpZmYpPerpendicType=bitor(NormalizePerpendicType,NormalizeByZpZmYpType);
        NormalizeByZpZmYmPerpendicType=bitor(NormalizePerpendicType,NormalizeByZpZmYmType);

        if(type==NormalizeByXpXmYpType)
            name{1}='Left(x+)';
            name{2}='Right(x-)';
            name{3}='Posterior(y+)';
        elseif(type==NormalizeByXpXmYmType)



            name{1}='LPA(x-)';
            name{2}='RPA(x+)';
            name{3}='nasion(y+)';
        elseif(type==NormalizeByXpXmZpType)
            name{1}='Left(x+)';
            name{2}='Right(x-)';
            name{3}='Head(z+)';
        elseif(type==NormalizeByXpXmZmType)
            name{1}='Left(x+)';
            name{2}='Right(x-)';
            name{3}='Foot(z-)';
        elseif(type==NormalizeByYmYpXpType)
            name{1}='Anterior(y-)';
            name{2}='Posterior(y+)';
            name{3}='Left(x+)';
        elseif(type==NormalizeByYmYpXmType)
            name{1}='Anterior(y-)';
            name{2}='Posterior(y+)';
            name{3}='Right(x-)';
        elseif(type==NormalizeByYmYpZpType)
            name{1}='Anterior(y-)';
            name{2}='Posterior(y+)';
            name{3}='Head(z+)';
        elseif(type==NormalizeByYmYpZmType)
            name{1}='Anterior(y-)';
            name{2}='Posterior(y+)';
            name{3}='Foot(z-)';
        elseif(type==NormalizeByZpZmXpType)
            name{1}='Head(z+)';
            name{2}='Foot(z-)';
            name{3}='Left(x+)';
        elseif(type==NormalizeByZpZmXmType)
            name{1}='Head(z+)';
            name{2}='Foot(z-)';
            name{3}='Right(x-)';
        elseif(type==NormalizeByZpZmYpType)
            name{1}='Head(z+)';
            name{2}='Foot(z-)';
            name{3}='Posterior(y+)';
        elseif(type==NormalizeByZpZmYmType)
            name{1}='Head(z+)';
            name{2}='Foot(z-)';
            name{3}='Anterior(y-)';
        elseif(type==NormalizeByXpXmYpPerpendicType)
            name{1}='Left(x+)(Perpendic)';
            name{2}='Right(x-)(Perpendic)';
            name{3}='Posterior(y+)(Perpendic)';
        elseif(type==NormalizeByXpXmYmPerpendicType)



            name{1}='LPA(x-)(Perpendic)';
            name{2}='RPA(x+)(Perpendic)';
            name{3}='nasion(y+)(Perpendic)';
        elseif(type==NormalizeByXpXmZpPerpendicType)
            name{1}='Left(x+)(Perpendic)';
            name{2}='Right(x-)(Perpendic)';
            name{3}='Head(z+)(Perpendic)';
        elseif(type==NormalizeByXpXmZmPerpendicType)
            name{1}='Left(x+)(Perpendic)';
            name{2}='Right(x-)(Perpendic)';
            name{3}='Foot(z-)(Perpendic)';
        elseif(type==NormalizeByYmYpXpPerpendicType)
            name{1}='Anterior(y-)(Perpendic)';
            name{2}='Posterior(y+)(Perpendic)';
            name{3}='Left(x+)(Perpendic)';
        elseif(type==NormalizeByYmYpXmPerpendicType)
            name{1}='Anterior(y-)(Perpendic)';
            name{2}='Posterior(y+)(Perpendic)';
            name{3}='Right(x-)(Perpendic)';
        elseif(type==NormalizeByYmYpZpPerpendicType)
            name{1}='Anterior(y-)(Perpendic)';
            name{2}='Posterior(y+)(Perpendic)';
            name{3}='Head(z+)(Perpendic)';
        elseif(type==NormalizeByYmYpZmPerpendicType)
            name{1}='Anterior(y-)(Perpendic)';
            name{2}='Posterior(y+)(Perpendic)';
            name{3}='Foot(z-)(Perpendic)';
        elseif(type==NormalizeByZpZmXpPerpendicType)
            name{1}='Head(z+)(Perpendic)';
            name{2}='Foot(z-)(Perpendic)';
            name{3}='Left(x+)(Perpendic)';
        elseif(type==NormalizeByZpZmXmPerpendicType)
            name{1}='Head(z+)(Perpendic)';
            name{2}='Foot(z-)(Perpendic)';
            name{3}='Right(x-)(Perpendic)';
        elseif(type==NormalizeByZpZmYpPerpendicType)
            name{1}='Head(z+)(Perpendic)';
            name{2}='Foot(z-)(Perpendic)';
            name{3}='Posterior(y+)(Perpendic)';
        elseif(type==NormalizeByZpZmYmPerpendicType)
            name{1}='Head(z+)(Perpendic)';
            name{2}='Foot(z-)(Perpendic)';
            name{3}='Anterior(y-)(Perpendic)';
        else
            name{1}='(Not defined)';
            name{2}='(Not defined)';
            name{3}='(Not defined)';
        end

