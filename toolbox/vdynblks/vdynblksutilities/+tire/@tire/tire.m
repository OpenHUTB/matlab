classdef tire<handle



    properties(Constant)
        DEFDir=fileparts(which('vehdynlib.slx'));
    end
    properties

        NAME,DIR
FILE_TYPE
FILE_VERSION
FILE_FORMAT
COMMENT

LENGTH
FORCE
ANGLE
TIME

FITTYP
TYRESIDE
LONGVL
VXLOW
ROAD_INCREMENT
ROAD_DIRECTION
PROPERTY_FILE_FORMAT
FUNCTION_NAME
N_TIRE_STATES
USE_MODE
HMAX_LOCAL
SWITCH_INTEG

UNLOADED_RADIUS
WIDTH
RIM_RADIUS
RIM_WIDTH
ASPECT_RATIO

INFLPRES
NOMPRES

MASS
IXX
IYY
BELT_MASS
BELT_IXX
BELT_IYY
GRAVITY

FNOMIN
VERTICAL_STIFFNESS
VERTICAL_DAMPING
MC_CONTOUR_A
MC_CONTOUR_B
BREFF
DREFF
FREFF
Q_RE0
Q_V1
Q_V2
        Q_FZ1=0
Q_FZ2
        Q_FZ3=0
Q_FCX
Q_FCY
Q_CAM
PFZ1
Q_FCY2
Q_CAM1
Q_CAM2
Q_CAM3
Q_FYS1
Q_FYS2
Q_FYS3
BOTTOM_OFFST
BOTTOM_STIFF

LONGITUDINAL_STIFFNESS
LATERAL_STIFFNESS
YAW_STIFFNESS
FREQ_LONG
FREQ_LAT
FREQ_YAW
FREQ_WINDUP
DAMP_LONG
DAMP_LAT
DAMP_YAW
DAMP_WINDUP
DAMP_RESIDUAL
DAMP_VLOW
Q_BVX
Q_BVT
PCFX1
PCFX2
PCFX3
PCFY1
PCFY2
PCFY3
PCMZ1

Q_RA1
Q_RA2
Q_RB1
Q_RB2
ELLIPS_SHIFT
ELLIPS_LENGTH
ELLIPS_HEIGHT
ELLIPS_ORDER
ELLIPS_MAX_STEP
ELLIPS_NWIDTH
ELLIPS_NLENGTH
ENV_C1
ENV_C2

PRESMAX
PRESMIN

FZMAX
FZMIN

KPUMAX
KPUMIN

ALPMAX
ALPMIN

CAMMIN
CAMMAX

LFZO
LCX
LMUX
LEX
LKX
LHX
LVX
LCY
LMUY
LEY
LKY
LKYC
LKZC
LHY
LVY
LTR
LRES
LXAL
LYKA
LVYKA
LS
LMX
LVMX
LMY
LMP

PCX1
PDX1
PDX2
PDX3
PEX1
PEX2
PEX3
PEX4
PKX1
PKX2
PKX3
PHX1
PHX2
PVX1
PVX2
PPX1
PPX2
PPX3
PPX4
RBX1
RBX2
RBX3
RCX1
REX1
REX2
RHX1

QSX1
QSX2
QSX3
QSX4
QSX5
QSX6
QSX7
QSX8
QSX9
QSX10
QSX11
QSX12
QSX13
QSX14
PPMX1

PCY1
PDY1
PDY2
PDY3
PEY1
PEY2
PEY3
PEY4
PEY5
PKY1
PKY2
PKY3
PKY4
PKY5
PKY6
PKY7
PHY1
PHY2
PVY1
PVY2
PVY3
PVY4
PPY1
PPY2
PPY3
PPY4
PPY5
RBY1
RBY2
RBY3
RBY4
RCY1
REY1
REY2
RHY1
RHY2
RVY1
RVY2
RVY3
RVY4
RVY5
RVY6

QSY1
QSY2
QSY3
QSY4
QSY5
QSY6
QSY7
QSY8

QBZ1
QBZ2
QBZ3
QBZ4
QBZ5
        QBZ6=0
QBZ9
QBZ10
QCZ1
QDZ1
QDZ2
QDZ3
QDZ4
QDZ6
QDZ7
QDZ8
QDZ9
QDZ10
QDZ11
QEZ1
QEZ2
QEZ3
QEZ4
QEZ5
QHZ1
QHZ2
QHZ3
QHZ4
PPZ1
PPZ2
SSZ1
SSZ2
SSZ3
SSZ4

PDXP1
PDXP2
PDXP3
PKYP1
PDYP1
PDYP2
PDYP3
PDYP4
PHYP1
PHYP2
PHYP3
PHYP4
PECP1
PECP2
QDTP1
QCRP1
QCRP2
QBRP1
QDRP1
        QDRP2=0
    end


    methods

        function trObj=tire(T,varargin)
            if nargin<1
                trObj.NAME='DefaultPassCar';
                trObj.DIR=tire.tire.DEFDir;




            else
                if ischar(T)
                    m=size(T,1);
                    n=1;
                    Tstr=T;
                    T=cell(m,n);
                    for idx=1:m
                        T{idx,1}=Tstr(idx,:);
                    end
                else
                    m=size(T,1);
                    n=size(T,2);
                end

                fileType=cell(m,n);

                trObj(m,n)=tire.tire;
                for i=1:m
                    for j=1:n
                        [trObj(i,j).DIR,trObj(i,j).NAME,fileType{i,j}]=fileparts(T{i,j});
                        if strcmpi(fileType{i,j},'.mat')
                            tr=load(T{i,j});
                            trProperties=whos('-file',T{i,j});
                            try
                                if string(trProperties.class)~="tire.tire"
                                    warning(message('vdynblks:vehdyntire:unknownSrcParam',trObj(i,j).NAME,[trObj(i,j).DIR,trObj(i,j).NAME]))
                                    [trObj(i,j),n]=trObj(i,j).importTireData([trObj(i,j).NAME,'.tir']);
                                else
                                    [trObj(i,j),n]=mat2Tire(tr,trProperties.name);
                                end
                            catch
                                error("MAT-file is incompatible. MAT-file should contain a single object of 'tire.tire' class.")
                            end
                        elseif strcmpi(fileType{i,j},'.tir')
                            [trObj(i,j),n]=trObj(i,j).importTireData([trObj(i,j).NAME,'.tir']);



                        elseif cmpTireName(string(T),'Light passenger car')
                            [trObj(i,j),n]=struct2Tire(tireMF20560R15('Novi'),'Light passenger car');
                        elseif cmpTireName(string(T),'Performance car')
                            [trObj(i,j),n]=struct2Tire(tireMF22540R19('Novi'),'Performance car');
                        elseif cmpTireName(string(T),'Light truck')
                            [trObj(i,j),n]=struct2Tire(tireMF27565R18('Novi'),'Light truck');
                        elseif cmpTireName(string(T),'Commercial truck')
                            [trObj(i,j),n]=struct2Tire(tireMF29575R22p5('Novi'),'Commerical truck');
                        elseif cmpTireName(string(T),'SUV')
                            [trObj(i,j),n]=struct2Tire(tireMF26550R20('Novi'),'SUV');
                        elseif cmpTireName(string(T),'Mid-size passenger car')
                            [trObj(i,j),n]=struct2Tire(tireMF23545R18('Novi'),'Mid-size passenger car');
                        else
                            warning(message('vdynblks:vehdyntire:wrongFileType',fileType{i,j}));
                            return
                        end
                        if~isempty(n)
                            warning("The numeric value of the following parameters are not defined: "+join(n(:)))
                        end
                    end
                end
            end

            function[tr,n]=mat2Tire(matStruct,name)
                tr=matStruct.(name);
                fn=fieldnames(tr);
                n=strings(length(fn));
                for ii=1:length(fn)
                    if ii>23&&isempty(tr.(fn{ii}))
                        n(ii)=string(fn{ii});
                    end
                end
                n=n(~(n==""));
            end

            function[tr,n]=struct2Tire(trArray,name)
                tr=tire.tire;
                fn=fieldnames(tr);
                tr.NAME=name;
                n=strings(length(fn));
                for ii=3:length(fn)
                    tr.(fn{ii})=trArray.(fn{ii});
                    if ii>23&&isempty(trArray.(fn{ii}))
                        n(ii)=string(fn{ii});
                    end
                end
                n=n(~(n==""));
            end

            function match=cmpTireName(in,type)

                in=char(in);type=char(type);

                checkstr=@(x)x==' '|x=='_'|x=='-'|x=='-';

                in(checkstr(in))=[];
                type(checkstr(type))=[];

                match=strcmpi(in,type);

            end
        end



        [tire,propNaN]=importTireData(tire,tir_filename);


        saveTire(tire);


        [tireStruct,tiresStruct,tireSimpStruct]=createStruct(tire);


        createVars(tire);


        setMaskVars(tire,block);


        genPcode(tire,pcodeName,pwd);


        d=computeTire(tireDataSrc,varargin)

    end



end