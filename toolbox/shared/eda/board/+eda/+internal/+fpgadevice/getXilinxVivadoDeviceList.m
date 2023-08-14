function r=getXilinxVivadoDeviceList(varargin)

    familyList={'Artix7','Kintex UltraScale+','Kintex7','KintexU','Spartan7','Virtex UltraScale+','Virtex7','VirtexU','Zynq','Zynq UltraScale+','Zynq UltraScale+ RFSoC',};
    if nargin==0
        r=familyList;
    else
        family=varargin{1};
        indx=find(strcmpi(family,familyList));
        if nargin==1
            r=getDevice(indx);
        else
            r=getDevice(indx,varargin{2:end});
        end
    end
end
function r=getDevice(idx,varargin)
    if idx==1
        if nargin==1
            r={'xc7a100t','xc7a100ti','xc7a12t','xc7a12ti','xc7a15t','xc7a15ti','xc7a200t','xc7a200ti','xc7a25t','xc7a25ti','xc7a35t','xc7a35ti','xc7a50t','xc7a50ti','xc7a75t','xc7a75ti',};
        elseif nargin==3
            if strcmpi(varargin{1},'xc7a100t')
                if strcmpi(varargin{2},'package')
                    r={'csg324','fgg484','fgg676','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a100ti')
                if strcmpi(varargin{2},'package')
                    r={'csg324','fgg484','fgg676','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a12t')
                if strcmpi(varargin{2},'package')
                    r={'cpg238','csg325',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a12ti')
                if strcmpi(varargin{2},'package')
                    r={'cpg238','csg325',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a15t')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a15ti')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a200t')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg1156','ffv1156','sbg484','sbv484',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a200ti')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg1156','ffv1156','sbg484','sbv484',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a25t')
                if strcmpi(varargin{2},'package')
                    r={'cpg238','csg325',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a25ti')
                if strcmpi(varargin{2},'package')
                    r={'cpg238','csg325',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a35t')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a35ti')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a50t')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a50ti')
                if strcmpi(varargin{2},'package')
                    r={'cpg236','csg324','csg325','fgg484','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7a75t')
                if strcmpi(varargin{2},'package')
                    r={'csg324','fgg484','fgg676','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7a75ti')
                if strcmpi(varargin{2},'package')
                    r={'csg324','fgg484','fgg676','ftg256',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            end
        end
    elseif idx==2
        if nargin==1
            r={'xcku11p-ffva1156-1-e','xcku11p-ffva1156-1-i','xcku11p-ffva1156-1L-i','xcku11p-ffva1156-1LV-i','xcku11p-ffva1156-2-e','xcku11p-ffva1156-2-i','xcku11p-ffva1156-2L-e','xcku11p-ffva1156-2LV-e','xcku11p-ffva1156-3-e','xcku11p-ffvd900-1-e','xcku11p-ffvd900-1-i','xcku11p-ffvd900-1L-i','xcku11p-ffvd900-1LV-i','xcku11p-ffvd900-2-e','xcku11p-ffvd900-2-i','xcku11p-ffvd900-2L-e','xcku11p-ffvd900-2LV-e','xcku11p-ffvd900-3-e','xcku11p-ffve1517-1-e','xcku11p-ffve1517-1-i','xcku11p-ffve1517-1L-i','xcku11p-ffve1517-1LV-i','xcku11p-ffve1517-2-e','xcku11p-ffve1517-2-i','xcku11p-ffve1517-2L-e','xcku11p-ffve1517-2LV-e','xcku11p-ffve1517-3-e','xcku11p_CIV-ffva1156-1-e','xcku11p_CIV-ffva1156-1-i','xcku11p_CIV-ffva1156-1L-i','xcku11p_CIV-ffva1156-1LV-i','xcku11p_CIV-ffva1156-2-e','xcku11p_CIV-ffva1156-2-i','xcku11p_CIV-ffva1156-2L-e','xcku11p_CIV-ffva1156-2LV-e','xcku11p_CIV-ffva1156-3-e','xcku11p_CIV-ffvd900-1-e','xcku11p_CIV-ffvd900-1-i','xcku11p_CIV-ffvd900-1L-i','xcku11p_CIV-ffvd900-1LV-i','xcku11p_CIV-ffvd900-2-e','xcku11p_CIV-ffvd900-2-i','xcku11p_CIV-ffvd900-2L-e','xcku11p_CIV-ffvd900-2LV-e','xcku11p_CIV-ffvd900-3-e','xcku11p_CIV-ffve1517-1-e','xcku11p_CIV-ffve1517-1-i','xcku11p_CIV-ffve1517-1L-i','xcku11p_CIV-ffve1517-1LV-i','xcku11p_CIV-ffve1517-2-e','xcku11p_CIV-ffve1517-2-i','xcku11p_CIV-ffve1517-2L-e','xcku11p_CIV-ffve1517-2LV-e','xcku11p_CIV-ffve1517-3-e','xcku13p-ffve900-1-e','xcku13p-ffve900-1-i','xcku13p-ffve900-1L-i','xcku13p-ffve900-1LV-i','xcku13p-ffve900-2-e','xcku13p-ffve900-2-i','xcku13p-ffve900-2L-e','xcku13p-ffve900-2LV-e','xcku13p-ffve900-3-e','xcku15p-ffva1156-1-e','xcku15p-ffva1156-1-i','xcku15p-ffva1156-1L-i','xcku15p-ffva1156-1LV-i','xcku15p-ffva1156-2-e','xcku15p-ffva1156-2-i','xcku15p-ffva1156-2L-e','xcku15p-ffva1156-2LV-e','xcku15p-ffva1156-3-e','xcku15p-ffva1760-1-e','xcku15p-ffva1760-1-i','xcku15p-ffva1760-1L-i','xcku15p-ffva1760-1LV-i','xcku15p-ffva1760-2-e','xcku15p-ffva1760-2-i','xcku15p-ffva1760-2L-e','xcku15p-ffva1760-2LV-e','xcku15p-ffva1760-3-e','xcku15p-ffve1517-1-e','xcku15p-ffve1517-1-i','xcku15p-ffve1517-1L-i','xcku15p-ffve1517-1LV-i','xcku15p-ffve1517-2-e','xcku15p-ffve1517-2-i','xcku15p-ffve1517-2L-e','xcku15p-ffve1517-2LV-e','xcku15p-ffve1517-3-e','xcku15p-ffve1760-1-e','xcku15p-ffve1760-1-i','xcku15p-ffve1760-1L-i','xcku15p-ffve1760-1LV-i','xcku15p-ffve1760-2-e','xcku15p-ffve1760-2-i','xcku15p-ffve1760-2L-e','xcku15p-ffve1760-2LV-e','xcku15p-ffve1760-3-e','xcku15p_CIV-ffva1156-1-e','xcku15p_CIV-ffva1156-1-i','xcku15p_CIV-ffva1156-1L-i','xcku15p_CIV-ffva1156-1LV-i','xcku15p_CIV-ffva1156-2-e','xcku15p_CIV-ffva1156-2-i','xcku15p_CIV-ffva1156-2L-e','xcku15p_CIV-ffva1156-2LV-e','xcku15p_CIV-ffva1156-3-e','xcku15p_CIV-ffva1760-1-e','xcku15p_CIV-ffva1760-1-i','xcku15p_CIV-ffva1760-1L-i','xcku15p_CIV-ffva1760-1LV-i','xcku15p_CIV-ffva1760-2-e','xcku15p_CIV-ffva1760-2-i','xcku15p_CIV-ffva1760-2L-e','xcku15p_CIV-ffva1760-2LV-e','xcku15p_CIV-ffva1760-3-e','xcku15p_CIV-ffve1517-1-e','xcku15p_CIV-ffve1517-1-i','xcku15p_CIV-ffve1517-1L-i','xcku15p_CIV-ffve1517-1LV-i','xcku15p_CIV-ffve1517-2-e','xcku15p_CIV-ffve1517-2-i','xcku15p_CIV-ffve1517-2L-e','xcku15p_CIV-ffve1517-2LV-e','xcku15p_CIV-ffve1517-3-e','xcku15p_CIV-ffve1760-1-e','xcku15p_CIV-ffve1760-1-i','xcku15p_CIV-ffve1760-1L-i','xcku15p_CIV-ffve1760-1LV-i','xcku15p_CIV-ffve1760-2-e','xcku15p_CIV-ffve1760-2-i','xcku15p_CIV-ffve1760-2L-e','xcku15p_CIV-ffve1760-2LV-e','xcku15p_CIV-ffve1760-3-e','xcku3p-ffva676-1-e','xcku3p-ffva676-1-i','xcku3p-ffva676-1L-i','xcku3p-ffva676-1LV-i','xcku3p-ffva676-2-e','xcku3p-ffva676-2-i','xcku3p-ffva676-2L-e','xcku3p-ffva676-2LV-e','xcku3p-ffva676-3-e','xcku3p-ffvb676-1-e','xcku3p-ffvb676-1-i','xcku3p-ffvb676-1L-i','xcku3p-ffvb676-1LV-i','xcku3p-ffvb676-2-e','xcku3p-ffvb676-2-i','xcku3p-ffvb676-2L-e','xcku3p-ffvb676-2LV-e','xcku3p-ffvb676-3-e','xcku3p-ffvd900-1-e','xcku3p-ffvd900-1-i','xcku3p-ffvd900-1L-i','xcku3p-ffvd900-1LV-i','xcku3p-ffvd900-2-e','xcku3p-ffvd900-2-i','xcku3p-ffvd900-2L-e','xcku3p-ffvd900-2LV-e','xcku3p-ffvd900-3-e','xcku3p-sfvb784-1-e','xcku3p-sfvb784-1-i','xcku3p-sfvb784-1L-i','xcku3p-sfvb784-1LV-i','xcku3p-sfvb784-2-e','xcku3p-sfvb784-2-i','xcku3p-sfvb784-2L-e','xcku3p-sfvb784-2LV-e','xcku3p-sfvb784-3-e','xcku5p-ffva676-1-e','xcku5p-ffva676-1-i','xcku5p-ffva676-1L-i','xcku5p-ffva676-1LV-i','xcku5p-ffva676-2-e','xcku5p-ffva676-2-i','xcku5p-ffva676-2L-e','xcku5p-ffva676-2LV-e','xcku5p-ffva676-3-e','xcku5p-ffvb676-1-e','xcku5p-ffvb676-1-i','xcku5p-ffvb676-1L-i','xcku5p-ffvb676-1LV-i','xcku5p-ffvb676-2-e','xcku5p-ffvb676-2-i','xcku5p-ffvb676-2L-e','xcku5p-ffvb676-2LV-e','xcku5p-ffvb676-3-e','xcku5p-ffvd900-1-e','xcku5p-ffvd900-1-i','xcku5p-ffvd900-1L-i','xcku5p-ffvd900-1LV-i','xcku5p-ffvd900-2-e','xcku5p-ffvd900-2-i','xcku5p-ffvd900-2L-e','xcku5p-ffvd900-2LV-e','xcku5p-ffvd900-3-e','xcku5p-sfvb784-1-e','xcku5p-sfvb784-1-i','xcku5p-sfvb784-1L-i','xcku5p-sfvb784-1LV-i','xcku5p-sfvb784-2-e','xcku5p-sfvb784-2-i','xcku5p-sfvb784-2L-e','xcku5p-sfvb784-2LV-e','xcku5p-sfvb784-3-e','xcku5p_CIV-ffva676-2-e','xcku5p_CIV-ffva676-2-i','xcku5p_CIV-ffva676-2L-e','xcku5p_CIV-ffva676-2LV-e','xcku5p_CIV-ffva676-3-e','xcku5p_CIV-ffvb676-2-e','xcku5p_CIV-ffvb676-2-i','xcku5p_CIV-ffvb676-2L-e','xcku5p_CIV-ffvb676-2LV-e','xcku5p_CIV-ffvb676-3-e','xcku5p_CIV-ffvd900-2-e','xcku5p_CIV-ffvd900-2-i','xcku5p_CIV-ffvd900-2L-e','xcku5p_CIV-ffvd900-2LV-e','xcku5p_CIV-ffvd900-3-e','xcku5p_CIV-sfvb784-2-e','xcku5p_CIV-sfvb784-2-i','xcku5p_CIV-sfvb784-2L-e','xcku5p_CIV-sfvb784-2LV-e','xcku5p_CIV-sfvb784-3-e','xcku9p-ffve900-1-e','xcku9p-ffve900-1-i','xcku9p-ffve900-1L-i','xcku9p-ffve900-1LV-i','xcku9p-ffve900-2-e','xcku9p-ffve900-2-i','xcku9p-ffve900-2L-e','xcku9p-ffve900-2LV-e','xcku9p-ffve900-3-e',};
        else
            r={''};
        end
    elseif idx==3
        if nargin==1
            r={'xc7k160t','xc7k160ti','xc7k325t','xc7k325ti','xc7k355t','xc7k355ti','xc7k410t','xc7k410ti','xc7k420t','xc7k420ti','xc7k480t','xc7k480ti','xc7k70t',};
        elseif nargin==3
            if strcmpi(varargin{1},'xc7k160t')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg676','ffv676',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k160ti')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg676','ffv676',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k325t')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbg900','fbv676','fbv900','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k325ti')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbg900','fbv676','fbv900','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k355t')
                if strcmpi(varargin{2},'package')
                    r={'ffg901','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k355ti')
                if strcmpi(varargin{2},'package')
                    r={'ffg901','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k410t')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbg900','fbv676','fbv900','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k410ti')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbg900','fbv676','fbv900','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k420t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg901','ffv1156','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k420ti')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg901','ffv1156','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k480t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg901','ffv1156','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7k480ti')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg901','ffv1156','ffv901',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7k70t')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            end
        end
    elseif idx==4
        if nargin==1
            r={'xcku025-ffva1156-1-c','xcku025-ffva1156-1-i','xcku025-ffva1156-2-e','xcku025-ffva1156-2-i','xcku035-fbva676-1-c','xcku035-fbva676-1-i','xcku035-fbva676-1L-i','xcku035-fbva676-1LV-i','xcku035-fbva676-2-e','xcku035-fbva676-2-i','xcku035-fbva676-3-e','xcku035-fbva900-1-c','xcku035-fbva900-1-i','xcku035-fbva900-1L-i','xcku035-fbva900-1LV-i','xcku035-fbva900-2-e','xcku035-fbva900-2-i','xcku035-fbva900-3-e','xcku035-ffva1156-1-c','xcku035-ffva1156-1-i','xcku035-ffva1156-1L-i','xcku035-ffva1156-1LV-i','xcku035-ffva1156-2-e','xcku035-ffva1156-2-i','xcku035-ffva1156-3-e','xcku035-sfva784-1-c','xcku035-sfva784-1-i','xcku035-sfva784-1L-i','xcku035-sfva784-1LV-i','xcku035-sfva784-2-e','xcku035-sfva784-2-i','xcku035-sfva784-3-e','xcku040-fbva676-1-c','xcku040-fbva676-1-i','xcku040-fbva676-1L-i','xcku040-fbva676-1LV-i','xcku040-fbva676-2-e','xcku040-fbva676-2-i','xcku040-fbva676-3-e','xcku040-fbva900-1-c','xcku040-fbva900-1-i','xcku040-fbva900-1L-i','xcku040-fbva900-1LV-i','xcku040-fbva900-2-e','xcku040-fbva900-2-i','xcku040-fbva900-3-e','xcku040-ffva1156-1-c','xcku040-ffva1156-1-i','xcku040-ffva1156-1L-i','xcku040-ffva1156-1LV-i','xcku040-ffva1156-2-e','xcku040-ffva1156-2-i','xcku040-ffva1156-3-e','xcku040-sfva784-1-c','xcku040-sfva784-1-i','xcku040-sfva784-1L-i','xcku040-sfva784-1LV-i','xcku040-sfva784-2-e','xcku040-sfva784-2-i','xcku040-sfva784-3-e','xcku060-ffva1156-1-c','xcku060-ffva1156-1-i','xcku060-ffva1156-1L-i','xcku060-ffva1156-1LV-i','xcku060-ffva1156-2-e','xcku060-ffva1156-2-i','xcku060-ffva1156-3-e','xcku060-ffva1517-1-c','xcku060-ffva1517-1-i','xcku060-ffva1517-1L-i','xcku060-ffva1517-1LV-i','xcku060-ffva1517-2-e','xcku060-ffva1517-2-i','xcku060-ffva1517-3-e','xcku060_CIV-ffva1156-2-e','xcku060_CIV-ffva1156-2-i','xcku060_CIV-ffva1156-3-e','xcku060_CIV-ffva1517-2-e','xcku060_CIV-ffva1517-2-i','xcku060_CIV-ffva1517-3-e','xcku085-flva1517-1-c','xcku085-flva1517-1-i','xcku085-flva1517-1L-i','xcku085-flva1517-1LV-i','xcku085-flva1517-2-e','xcku085-flva1517-2-i','xcku085-flva1517-3-e','xcku085-flvb1760-1-c','xcku085-flvb1760-1-i','xcku085-flvb1760-1L-i','xcku085-flvb1760-1LV-i','xcku085-flvb1760-2-e','xcku085-flvb1760-2-i','xcku085-flvb1760-3-e','xcku085-flvf1924-1-c','xcku085-flvf1924-1-i','xcku085-flvf1924-1L-i','xcku085-flvf1924-1LV-i','xcku085-flvf1924-2-e','xcku085-flvf1924-2-i','xcku085-flvf1924-3-e','xcku085_CIV-flva1517-1-c','xcku085_CIV-flva1517-1-i','xcku085_CIV-flva1517-1L-i','xcku085_CIV-flva1517-1LV-i','xcku085_CIV-flva1517-2-e','xcku085_CIV-flva1517-2-i','xcku085_CIV-flva1517-3-e','xcku085_CIV-flvb1760-1-c','xcku085_CIV-flvb1760-1-i','xcku085_CIV-flvb1760-1L-i','xcku085_CIV-flvb1760-1LV-i','xcku085_CIV-flvb1760-2-e','xcku085_CIV-flvb1760-2-i','xcku085_CIV-flvb1760-3-e','xcku085_CIV-flvf1924-1-c','xcku085_CIV-flvf1924-1-i','xcku085_CIV-flvf1924-1L-i','xcku085_CIV-flvf1924-1LV-i','xcku085_CIV-flvf1924-2-e','xcku085_CIV-flvf1924-2-i','xcku085_CIV-flvf1924-3-e','xcku115-flva1517-1-c','xcku115-flva1517-1-i','xcku115-flva1517-1L-i','xcku115-flva1517-1LV-i','xcku115-flva1517-2-e','xcku115-flva1517-2-i','xcku115-flva1517-3-e','xcku115-flva2104-1-c','xcku115-flva2104-1-i','xcku115-flva2104-1L-i','xcku115-flva2104-1LV-i','xcku115-flva2104-2-e','xcku115-flva2104-2-i','xcku115-flva2104-3-e','xcku115-flvb1760-1-c','xcku115-flvb1760-1-i','xcku115-flvb1760-1L-i','xcku115-flvb1760-1LV-i','xcku115-flvb1760-2-e','xcku115-flvb1760-2-i','xcku115-flvb1760-3-e','xcku115-flvb2104-1-c','xcku115-flvb2104-1-i','xcku115-flvb2104-1L-i','xcku115-flvb2104-1LV-i','xcku115-flvb2104-2-e','xcku115-flvb2104-2-i','xcku115-flvb2104-3-e','xcku115-flvd1517-1-c','xcku115-flvd1517-1-i','xcku115-flvd1517-1L-i','xcku115-flvd1517-1LV-i','xcku115-flvd1517-2-e','xcku115-flvd1517-2-i','xcku115-flvd1517-3-e','xcku115-flvd1924-1-c','xcku115-flvd1924-1-i','xcku115-flvd1924-1L-i','xcku115-flvd1924-1LV-i','xcku115-flvd1924-2-e','xcku115-flvd1924-2-i','xcku115-flvd1924-3-e','xcku115-flvf1924-1-c','xcku115-flvf1924-1-i','xcku115-flvf1924-1L-i','xcku115-flvf1924-1LV-i','xcku115-flvf1924-2-e','xcku115-flvf1924-2-i','xcku115-flvf1924-3-e','xcku115_CIV-flva1517-1-c','xcku115_CIV-flva1517-1-i','xcku115_CIV-flva1517-1L-i','xcku115_CIV-flva1517-1LV-i','xcku115_CIV-flva1517-2-e','xcku115_CIV-flva1517-2-i','xcku115_CIV-flva1517-3-e','xcku115_CIV-flva2104-1-c','xcku115_CIV-flva2104-1-i','xcku115_CIV-flva2104-1L-i','xcku115_CIV-flva2104-1LV-i','xcku115_CIV-flva2104-2-e','xcku115_CIV-flva2104-2-i','xcku115_CIV-flva2104-3-e','xcku115_CIV-flvb1760-1-c','xcku115_CIV-flvb1760-1-i','xcku115_CIV-flvb1760-1L-i','xcku115_CIV-flvb1760-1LV-i','xcku115_CIV-flvb1760-2-e','xcku115_CIV-flvb1760-2-i','xcku115_CIV-flvb1760-3-e','xcku115_CIV-flvb2104-1-c','xcku115_CIV-flvb2104-1-i','xcku115_CIV-flvb2104-1L-i','xcku115_CIV-flvb2104-1LV-i','xcku115_CIV-flvb2104-2-e','xcku115_CIV-flvb2104-2-i','xcku115_CIV-flvb2104-3-e','xcku115_CIV-flvd1517-1-c','xcku115_CIV-flvd1517-1-i','xcku115_CIV-flvd1517-1L-i','xcku115_CIV-flvd1517-1LV-i','xcku115_CIV-flvd1517-2-e','xcku115_CIV-flvd1517-2-i','xcku115_CIV-flvd1517-3-e','xcku115_CIV-flvd1924-1-c','xcku115_CIV-flvd1924-1-i','xcku115_CIV-flvd1924-1L-i','xcku115_CIV-flvd1924-1LV-i','xcku115_CIV-flvd1924-2-e','xcku115_CIV-flvd1924-2-i','xcku115_CIV-flvd1924-3-e','xcku115_CIV-flvf1924-1-c','xcku115_CIV-flvf1924-1-i','xcku115_CIV-flvf1924-1L-i','xcku115_CIV-flvf1924-1LV-i','xcku115_CIV-flvf1924-2-e','xcku115_CIV-flvf1924-2-i','xcku115_CIV-flvf1924-3-e','xcku095-ffva1156-1-c','xcku095-ffva1156-1-i','xcku095-ffva1156-2-e','xcku095-ffva1156-2-i','xcku095-ffvb1760-1-c','xcku095-ffvb1760-1-i','xcku095-ffvb1760-2-e','xcku095-ffvb1760-2-i','xcku095-ffvb2104-1-c','xcku095-ffvb2104-1-i','xcku095-ffvb2104-2-e','xcku095-ffvb2104-2-i','xcku095-ffvc1517-1-c','xcku095-ffvc1517-1-i','xcku095-ffvc1517-2-e','xcku095-ffvc1517-2-i',};
        else
            r={''};
        end
    elseif idx==5
        if nargin==1
            r={'xc7s6ftgb196-1','xc7s6ftgb196-1IL','xc7s6ftgb196-1Q','xc7s6ftgb196-2','xc7s6csga225-1','xc7s6csga225-1IL','xc7s6csga225-1Q','xc7s6csga225-2','xc7s6cpga196-1','xc7s6cpga196-1IL','xc7s6cpga196-1Q','xc7s6cpga196-2','xc7s15cpga196-1','xc7s15cpga196-1IL','xc7s15cpga196-1Q','xc7s15cpga196-2','xc7s15csga225-1','xc7s15csga225-1IL','xc7s15csga225-1Q','xc7s15csga225-2','xc7s15ftgb196-1','xc7s15ftgb196-1IL','xc7s15ftgb196-1Q','xc7s15ftgb196-2','xc7s25ftgb196-1','xc7s25ftgb196-1IL','xc7s25ftgb196-1Q','xc7s25ftgb196-2','xc7s25csga324-1','xc7s25csga324-1IL','xc7s25csga324-1Q','xc7s25csga324-2','xc7s25csga225-1','xc7s25csga225-1IL','xc7s25csga225-1Q','xc7s25csga225-2','xc7s50csga324-1','xc7s50csga324-1IL','xc7s50csga324-1Q','xc7s50csga324-2','xc7s50fgga484-1','xc7s50fgga484-1IL','xc7s50fgga484-1Q','xc7s50fgga484-2','xc7s50ftgb196-1','xc7s50ftgb196-1IL','xc7s50ftgb196-1Q','xc7s50ftgb196-2','xc7s100fgga676-1','xc7s100fgga676-1IL','xc7s100fgga676-1Q','xc7s100fgga676-2','xc7s100fgga484-1','xc7s100fgga484-1IL','xc7s100fgga484-1Q','xc7s100fgga484-2','xc7s75fgga484-1','xc7s75fgga484-1IL','xc7s75fgga484-1Q','xc7s75fgga484-2','xc7s75fgga676-1','xc7s75fgga676-1IL','xc7s75fgga676-1Q','xc7s75fgga676-2',};
        else
            r={''};
        end
    elseif idx==6
        if nargin==1
            r={'xcu200-fsgd2104-2-e','xcu250-figd2104-2-e','xcu250-figd2104-2L-e','xcu250-figd2104-2LV-e','xcvu11p-flga2577-1-e','xcvu11p-flga2577-1-i','xcvu11p-flga2577-2-e','xcvu11p-flga2577-2-i','xcvu11p-flga2577-2L-e','xcvu11p-flga2577-2LV-e','xcvu11p-flga2577-3-e','xcvu11p-flgb2104-1-e','xcvu11p-flgb2104-1-i','xcvu11p-flgb2104-2-e','xcvu11p-flgb2104-2-i','xcvu11p-flgb2104-2L-e','xcvu11p-flgb2104-2LV-e','xcvu11p-flgb2104-3-e','xcvu11p-flgc2104-1-e','xcvu11p-flgc2104-1-i','xcvu11p-flgc2104-2-e','xcvu11p-flgc2104-2-i','xcvu11p-flgc2104-2L-e','xcvu11p-flgc2104-2LV-e','xcvu11p-flgc2104-3-e','xcvu11p-flgf1924-1-e','xcvu11p-flgf1924-1-i','xcvu11p-flgf1924-2-e','xcvu11p-flgf1924-2-i','xcvu11p-flgf1924-2L-e','xcvu11p-flgf1924-2LV-e','xcvu11p-flgf1924-3-e','xcvu11p-fsgd2104-1-e','xcvu11p-fsgd2104-1-i','xcvu11p-fsgd2104-2-e','xcvu11p-fsgd2104-2-i','xcvu11p-fsgd2104-2L-e','xcvu11p-fsgd2104-2LV-e','xcvu11p-fsgd2104-3-e','xcvu11p_CIV-flga2577-1-e','xcvu11p_CIV-flga2577-1-i','xcvu11p_CIV-flga2577-2-e','xcvu11p_CIV-flga2577-2-i','xcvu11p_CIV-flga2577-2L-e','xcvu11p_CIV-flga2577-2LV-e','xcvu11p_CIV-flga2577-3-e','xcvu11p_CIV-flgb2104-1-e','xcvu11p_CIV-flgb2104-1-i','xcvu11p_CIV-flgb2104-2-e','xcvu11p_CIV-flgb2104-2-i','xcvu11p_CIV-flgb2104-2L-e','xcvu11p_CIV-flgb2104-2LV-e','xcvu11p_CIV-flgb2104-3-e','xcvu11p_CIV-flgc2104-1-e','xcvu11p_CIV-flgc2104-1-i','xcvu11p_CIV-flgc2104-2-e','xcvu11p_CIV-flgc2104-2-i','xcvu11p_CIV-flgc2104-2L-e','xcvu11p_CIV-flgc2104-2LV-e','xcvu11p_CIV-flgc2104-3-e','xcvu11p_CIV-flgf1924-1-e','xcvu11p_CIV-flgf1924-1-i','xcvu11p_CIV-flgf1924-2-e','xcvu11p_CIV-flgf1924-2-i','xcvu11p_CIV-flgf1924-2L-e','xcvu11p_CIV-flgf1924-2LV-e','xcvu11p_CIV-flgf1924-3-e','xcvu11p_CIV-fsgd2104-1-e','xcvu11p_CIV-fsgd2104-1-i','xcvu11p_CIV-fsgd2104-2-e','xcvu11p_CIV-fsgd2104-2-i','xcvu11p_CIV-fsgd2104-2L-e','xcvu11p_CIV-fsgd2104-2LV-e','xcvu11p_CIV-fsgd2104-3-e','xcvu13p-fhga2104-1-e','xcvu13p-fhga2104-1-i','xcvu13p-fhga2104-2-e','xcvu13p-fhga2104-2-i','xcvu13p-fhga2104-2L-e','xcvu13p-fhga2104-2LV-e','xcvu13p-fhga2104-3-e','xcvu13p-fhgb2104-1-e','xcvu13p-fhgb2104-1-i','xcvu13p-fhgb2104-2-e','xcvu13p-fhgb2104-2-i','xcvu13p-fhgb2104-2L-e','xcvu13p-fhgb2104-2LV-e','xcvu13p-fhgb2104-3-e','xcvu13p-fhgc2104-1-e','xcvu13p-fhgc2104-1-i','xcvu13p-fhgc2104-2-e','xcvu13p-fhgc2104-2-i','xcvu13p-fhgc2104-2L-e','xcvu13p-fhgc2104-2LV-e','xcvu13p-fhgc2104-3-e','xcvu13p-figd2104-1-e','xcvu13p-figd2104-1-i','xcvu13p-figd2104-2-e','xcvu13p-figd2104-2-i','xcvu13p-figd2104-2L-e','xcvu13p-figd2104-2LV-e','xcvu13p-figd2104-3-e','xcvu13p-flga2577-1-e','xcvu13p-flga2577-1-i','xcvu13p-flga2577-2-e','xcvu13p-flga2577-2-i','xcvu13p-flga2577-2L-e','xcvu13p-flga2577-2LV-e','xcvu13p-flga2577-3-e','xcvu13p-fsga2577-1-e','xcvu13p-fsga2577-1-i','xcvu13p-fsga2577-2-e','xcvu13p-fsga2577-2-i','xcvu13p-fsga2577-2L-e','xcvu13p-fsga2577-2LV-e','xcvu13p-fsga2577-3-e','xcvu13p_CIV-fhga2104-1-e','xcvu13p_CIV-fhga2104-1-i','xcvu13p_CIV-fhga2104-2-e','xcvu13p_CIV-fhga2104-2-i','xcvu13p_CIV-fhga2104-2L-e','xcvu13p_CIV-fhga2104-2LV-e','xcvu13p_CIV-fhga2104-3-e','xcvu13p_CIV-fhgb2104-1-e','xcvu13p_CIV-fhgb2104-1-i','xcvu13p_CIV-fhgb2104-2-e','xcvu13p_CIV-fhgb2104-2-i','xcvu13p_CIV-fhgb2104-2L-e','xcvu13p_CIV-fhgb2104-2LV-e','xcvu13p_CIV-fhgb2104-3-e','xcvu13p_CIV-fhgc2104-1-e','xcvu13p_CIV-fhgc2104-1-i','xcvu13p_CIV-fhgc2104-2-e','xcvu13p_CIV-fhgc2104-2-i','xcvu13p_CIV-fhgc2104-2L-e','xcvu13p_CIV-fhgc2104-2LV-e','xcvu13p_CIV-fhgc2104-3-e','xcvu13p_CIV-figd2104-1-e','xcvu13p_CIV-figd2104-1-i','xcvu13p_CIV-figd2104-2-e','xcvu13p_CIV-figd2104-2-i','xcvu13p_CIV-figd2104-2L-e','xcvu13p_CIV-figd2104-2LV-e','xcvu13p_CIV-figd2104-3-e','xcvu13p_CIV-flga2577-1-e','xcvu13p_CIV-flga2577-1-i','xcvu13p_CIV-flga2577-2-e','xcvu13p_CIV-flga2577-2-i','xcvu13p_CIV-flga2577-2L-e','xcvu13p_CIV-flga2577-2LV-e','xcvu13p_CIV-flga2577-3-e','xcvu13p_CIV-fsga2577-1-e','xcvu13p_CIV-fsga2577-1-i','xcvu13p_CIV-fsga2577-2-e','xcvu13p_CIV-fsga2577-2-i','xcvu13p_CIV-fsga2577-2L-e','xcvu13p_CIV-fsga2577-2LV-e','xcvu13p_CIV-fsga2577-3-e','xcvu3p-ffvc1517-1-e','xcvu3p-ffvc1517-1-i','xcvu3p-ffvc1517-2-e','xcvu3p-ffvc1517-2-i','xcvu3p-ffvc1517-2L-e','xcvu3p-ffvc1517-2LV-e','xcvu3p-ffvc1517-3-e','xcvu3p_CIV-ffvc1517-1-e','xcvu3p_CIV-ffvc1517-1-i','xcvu3p_CIV-ffvc1517-2-e','xcvu3p_CIV-ffvc1517-2-i','xcvu3p_CIV-ffvc1517-2L-e','xcvu3p_CIV-ffvc1517-2LV-e','xcvu3p_CIV-ffvc1517-3-e','xcvu5p-flva2104-1-e','xcvu5p-flva2104-1-i','xcvu5p-flva2104-2-e','xcvu5p-flva2104-2-i','xcvu5p-flva2104-2L-e','xcvu5p-flva2104-2LV-e','xcvu5p-flva2104-3-e','xcvu5p-flvb2104-1-e','xcvu5p-flvb2104-1-i','xcvu5p-flvb2104-2-e','xcvu5p-flvb2104-2-i','xcvu5p-flvb2104-2L-e','xcvu5p-flvb2104-2LV-e','xcvu5p-flvb2104-3-e','xcvu5p-flvc2104-1-e','xcvu5p-flvc2104-1-i','xcvu5p-flvc2104-2-e','xcvu5p-flvc2104-2-i','xcvu5p-flvc2104-2L-e','xcvu5p-flvc2104-2LV-e','xcvu5p-flvc2104-3-e','xcvu5p_CIV-flva2104-1-e','xcvu5p_CIV-flva2104-1-i','xcvu5p_CIV-flva2104-2-e','xcvu5p_CIV-flva2104-2-i','xcvu5p_CIV-flva2104-2L-e','xcvu5p_CIV-flva2104-2LV-e','xcvu5p_CIV-flva2104-3-e','xcvu5p_CIV-flvb2104-1-e','xcvu5p_CIV-flvb2104-1-i','xcvu5p_CIV-flvb2104-2-e','xcvu5p_CIV-flvb2104-2-i','xcvu5p_CIV-flvb2104-2L-e','xcvu5p_CIV-flvb2104-2LV-e','xcvu5p_CIV-flvb2104-3-e','xcvu5p_CIV-flvc2104-1-e','xcvu5p_CIV-flvc2104-1-i','xcvu5p_CIV-flvc2104-2-e','xcvu5p_CIV-flvc2104-2-i','xcvu5p_CIV-flvc2104-2L-e','xcvu5p_CIV-flvc2104-2LV-e','xcvu5p_CIV-flvc2104-3-e','xcvu7p-flva2104-1-e','xcvu7p-flva2104-1-i','xcvu7p-flva2104-2-e','xcvu7p-flva2104-2-i','xcvu7p-flva2104-2L-e','xcvu7p-flva2104-2LV-e','xcvu7p-flva2104-3-e','xcvu7p-flvb2104-1-e','xcvu7p-flvb2104-1-i','xcvu7p-flvb2104-2-e','xcvu7p-flvb2104-2-i','xcvu7p-flvb2104-2L-e','xcvu7p-flvb2104-2LV-e','xcvu7p-flvb2104-3-e','xcvu7p-flvc2104-1-e','xcvu7p-flvc2104-1-i','xcvu7p-flvc2104-2-e','xcvu7p-flvc2104-2-i','xcvu7p-flvc2104-2L-e','xcvu7p-flvc2104-2LV-e','xcvu7p-flvc2104-3-e','xcvu7p_CIV-flva2104-1-e','xcvu7p_CIV-flva2104-1-i','xcvu7p_CIV-flva2104-2-e','xcvu7p_CIV-flva2104-2-i','xcvu7p_CIV-flva2104-2L-e','xcvu7p_CIV-flva2104-2LV-e','xcvu7p_CIV-flva2104-3-e','xcvu7p_CIV-flvb2104-1-e','xcvu7p_CIV-flvb2104-1-i','xcvu7p_CIV-flvb2104-2-e','xcvu7p_CIV-flvb2104-2-i','xcvu7p_CIV-flvb2104-2L-e','xcvu7p_CIV-flvb2104-2LV-e','xcvu7p_CIV-flvb2104-3-e','xcvu7p_CIV-flvc2104-1-e','xcvu7p_CIV-flvc2104-1-i','xcvu7p_CIV-flvc2104-2-e','xcvu7p_CIV-flvc2104-2-i','xcvu7p_CIV-flvc2104-2L-e','xcvu7p_CIV-flvc2104-2LV-e','xcvu7p_CIV-flvc2104-3-e','xcvu9p-flga2104-1-e','xcvu9p-flga2104-1-i','xcvu9p-flga2104-2-e','xcvu9p-flga2104-2-i','xcvu9p-flga2104-2L-e','xcvu9p-flga2104-2LV-e','xcvu9p-flga2104-3-e','xcvu9p-flga2577-1-e','xcvu9p-flga2577-1-i','xcvu9p-flga2577-2-e','xcvu9p-flga2577-2-i','xcvu9p-flga2577-2L-e','xcvu9p-flga2577-2LV-e','xcvu9p-flga2577-3-e','xcvu9p-flgb2104-1-e','xcvu9p-flgb2104-1-i','xcvu9p-flgb2104-2-e','xcvu9p-flgb2104-2-i','xcvu9p-flgb2104-2L-e','xcvu9p-flgb2104-2LV-e','xcvu9p-flgb2104-3-e','xcvu9p-flgc2104-1-e','xcvu9p-flgc2104-1-i','xcvu9p-flgc2104-2-e','xcvu9p-flgc2104-2-i','xcvu9p-flgc2104-2L-e','xcvu9p-flgc2104-2LV-e','xcvu9p-flgc2104-3-e','xcvu9p-fsgd2104-1-e','xcvu9p-fsgd2104-1-i','xcvu9p-fsgd2104-2-e','xcvu9p-fsgd2104-2-i','xcvu9p-fsgd2104-2L-e','xcvu9p-fsgd2104-2LV-e','xcvu9p-fsgd2104-3-e','xcvu9p_CIV-flga2104-1-e','xcvu9p_CIV-flga2104-1-i','xcvu9p_CIV-flga2104-2-e','xcvu9p_CIV-flga2104-2-i','xcvu9p_CIV-flga2104-2L-e','xcvu9p_CIV-flga2104-2LV-e','xcvu9p_CIV-flga2104-3-e','xcvu9p_CIV-flga2577-1-e','xcvu9p_CIV-flga2577-1-i','xcvu9p_CIV-flga2577-2-e','xcvu9p_CIV-flga2577-2-i','xcvu9p_CIV-flga2577-2L-e','xcvu9p_CIV-flga2577-2LV-e','xcvu9p_CIV-flga2577-3-e','xcvu9p_CIV-flgb2104-1-e','xcvu9p_CIV-flgb2104-1-i','xcvu9p_CIV-flgb2104-2-e','xcvu9p_CIV-flgb2104-2-i','xcvu9p_CIV-flgb2104-2L-e','xcvu9p_CIV-flgb2104-2LV-e','xcvu9p_CIV-flgb2104-3-e','xcvu9p_CIV-flgc2104-1-e','xcvu9p_CIV-flgc2104-1-i','xcvu9p_CIV-flgc2104-2-e','xcvu9p_CIV-flgc2104-2-i','xcvu9p_CIV-flgc2104-2L-e','xcvu9p_CIV-flgc2104-2LV-e','xcvu9p_CIV-flgc2104-3-e','xcvu9p_CIV-fsgd2104-1-e','xcvu9p_CIV-fsgd2104-1-i','xcvu9p_CIV-fsgd2104-2-e','xcvu9p_CIV-fsgd2104-2-i','xcvu9p_CIV-fsgd2104-2L-e','xcvu9p_CIV-fsgd2104-2LV-e','xcvu9p_CIV-fsgd2104-3-e','xcvu19p-fsva3824-1-e','xcvu19p-fsva3824-2-e','xcvu19p-fsvb3824-1-e','xcvu19p-fsvb3824-2-e',};
        else
            r={''};
        end
    elseif idx==7
        if nargin==1
            r={'xc7v2000t','xc7v585t','xc7vh580t','xc7vh870t','xc7vx1140t','xc7vx330t','xc7vx415t','xc7vx415t_CIV','xc7vx485t','xc7vx550t','xc7vx550t_CIV','xc7vx690t','xc7vx690t_CIV','xc7vx980t',};
        elseif nargin==3
            if strcmpi(varargin{1},'xc7v2000t')
                if strcmpi(varargin{2},'package')
                    r={'fhg1761','flg1925',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2G','-2L',};
                end
            elseif strcmpi(varargin{1},'xc7v585t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1761',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vh580t')
                if strcmpi(varargin{2},'package')
                    r={'flg1155','flg1931','hcg1155','hcg1931',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2G','-2L',};
                end
            elseif strcmpi(varargin{1},'xc7vh870t')
                if strcmpi(varargin{2},'package')
                    r={'flg1932','hcg1932',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2G','-2L',};
                end
            elseif strcmpi(varargin{1},'xc7vx1140t')
                if strcmpi(varargin{2},'package')
                    r={'flg1926','flg1928','flg1930',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2G','-2L',};
                end
            elseif strcmpi(varargin{1},'xc7vx330t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1761','ffv1157','ffv1761',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx415t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1158','ffg1927','ffv1157','ffv1158','ffv1927',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx415t_CIV')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1158','ffg1927','ffv1157','ffv1158','ffv1927',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx485t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1158','ffg1761','ffg1927','ffg1930',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx550t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1158','ffg1927',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx550t_CIV')
                if strcmpi(varargin{2},'package')
                    r={'ffg1158','ffg1927',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx690t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1158','ffg1761','ffg1926','ffg1927','ffg1930',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx690t_CIV')
                if strcmpi(varargin{2},'package')
                    r={'ffg1157','ffg1158','ffg1761','ffg1926','ffg1927','ffg1930',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L','-3',};
                end
            elseif strcmpi(varargin{1},'xc7vx980t')
                if strcmpi(varargin{2},'package')
                    r={'ffg1926','ffg1928','ffg1930',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-2L',};
                end
            end
        end
    elseif idx==8
        if nargin==1
            r={'xcvu065-ffvc1517-1-i','xcvu065-ffvc1517-1H-e','xcvu065-ffvc1517-1HV-e','xcvu065-ffvc1517-2-e','xcvu065-ffvc1517-2-i','xcvu065-ffvc1517-3-e','xcvu065_CIV-ffvc1517-1-i','xcvu065_CIV-ffvc1517-1H-e','xcvu065_CIV-ffvc1517-1HV-e','xcvu065_CIV-ffvc1517-2-e','xcvu065_CIV-ffvc1517-2-i','xcvu065_CIV-ffvc1517-3-e','xcvu080-ffva2104-1-i','xcvu080-ffva2104-1H-e','xcvu080-ffva2104-1HV-e','xcvu080-ffva2104-2-e','xcvu080-ffva2104-2-i','xcvu080-ffva2104-3-e','xcvu080-ffvb1760-1-i','xcvu080-ffvb1760-1H-e','xcvu080-ffvb1760-1HV-e','xcvu080-ffvb1760-2-e','xcvu080-ffvb1760-2-i','xcvu080-ffvb1760-3-e','xcvu080-ffvb2104-1-i','xcvu080-ffvb2104-1H-e','xcvu080-ffvb2104-1HV-e','xcvu080-ffvb2104-2-e','xcvu080-ffvb2104-2-i','xcvu080-ffvb2104-3-e','xcvu080-ffvc1517-1-i','xcvu080-ffvc1517-1H-e','xcvu080-ffvc1517-1HV-e','xcvu080-ffvc1517-2-e','xcvu080-ffvc1517-2-i','xcvu080-ffvc1517-3-e','xcvu080-ffvd1517-1-i','xcvu080-ffvd1517-1H-e','xcvu080-ffvd1517-1HV-e','xcvu080-ffvd1517-2-e','xcvu080-ffvd1517-2-i','xcvu080-ffvd1517-3-e','xcvu095-ffva2104-1-i','xcvu095-ffva2104-1H-e','xcvu095-ffva2104-1HV-e','xcvu095-ffva2104-2-e','xcvu095-ffva2104-2-i','xcvu095-ffva2104-3-e','xcvu095-ffvb1760-1-i','xcvu095-ffvb1760-1H-e','xcvu095-ffvb1760-1HV-e','xcvu095-ffvb1760-2-e','xcvu095-ffvb1760-2-i','xcvu095-ffvb1760-3-e','xcvu095-ffvb2104-1-i','xcvu095-ffvb2104-1H-e','xcvu095-ffvb2104-1HV-e','xcvu095-ffvb2104-2-e','xcvu095-ffvb2104-2-i','xcvu095-ffvb2104-3-e','xcvu095-ffvc1517-1-i','xcvu095-ffvc1517-1H-e','xcvu095-ffvc1517-1HV-e','xcvu095-ffvc1517-2-e','xcvu095-ffvc1517-2-i','xcvu095-ffvc1517-3-e','xcvu095-ffvc2104-1-i','xcvu095-ffvc2104-1H-e','xcvu095-ffvc2104-1HV-e','xcvu095-ffvc2104-2-e','xcvu095-ffvc2104-2-i','xcvu095-ffvc2104-3-e','xcvu095-ffvd1517-1-i','xcvu095-ffvd1517-1H-e','xcvu095-ffvd1517-1HV-e','xcvu095-ffvd1517-2-e','xcvu095-ffvd1517-2-i','xcvu095-ffvd1517-3-e','xcvu095_CIV-ffva2104-1-i','xcvu095_CIV-ffva2104-1H-e','xcvu095_CIV-ffva2104-1HV-e','xcvu095_CIV-ffva2104-2-e','xcvu095_CIV-ffva2104-2-i','xcvu095_CIV-ffva2104-3-e','xcvu095_CIV-ffvb1760-1-i','xcvu095_CIV-ffvb1760-1H-e','xcvu095_CIV-ffvb1760-1HV-e','xcvu095_CIV-ffvb1760-2-e','xcvu095_CIV-ffvb1760-2-i','xcvu095_CIV-ffvb1760-3-e','xcvu095_CIV-ffvb2104-1-i','xcvu095_CIV-ffvb2104-1H-e','xcvu095_CIV-ffvb2104-1HV-e','xcvu095_CIV-ffvb2104-2-e','xcvu095_CIV-ffvb2104-2-i','xcvu095_CIV-ffvb2104-3-e','xcvu095_CIV-ffvc1517-1-i','xcvu095_CIV-ffvc1517-1H-e','xcvu095_CIV-ffvc1517-1HV-e','xcvu095_CIV-ffvc1517-2-e','xcvu095_CIV-ffvc1517-2-i','xcvu095_CIV-ffvc1517-3-e','xcvu095_CIV-ffvc2104-1-i','xcvu095_CIV-ffvc2104-1H-e','xcvu095_CIV-ffvc2104-1HV-e','xcvu095_CIV-ffvc2104-2-e','xcvu095_CIV-ffvc2104-2-i','xcvu095_CIV-ffvc2104-3-e','xcvu095_CIV-ffvd1517-1-i','xcvu095_CIV-ffvd1517-1H-e','xcvu095_CIV-ffvd1517-1HV-e','xcvu095_CIV-ffvd1517-2-e','xcvu095_CIV-ffvd1517-2-i','xcvu095_CIV-ffvd1517-3-e','xcvu125-flva2104-1-i','xcvu125-flva2104-1H-e','xcvu125-flva2104-1HV-e','xcvu125-flva2104-2-e','xcvu125-flva2104-2-i','xcvu125-flva2104-3-e','xcvu125-flvb1760-1-i','xcvu125-flvb1760-1H-e','xcvu125-flvb1760-1HV-e','xcvu125-flvb1760-2-e','xcvu125-flvb1760-2-i','xcvu125-flvb1760-3-e','xcvu125-flvb2104-1-i','xcvu125-flvb2104-1H-e','xcvu125-flvb2104-1HV-e','xcvu125-flvb2104-2-e','xcvu125-flvb2104-2-i','xcvu125-flvb2104-3-e','xcvu125-flvc2104-1-i','xcvu125-flvc2104-1H-e','xcvu125-flvc2104-1HV-e','xcvu125-flvc2104-2-e','xcvu125-flvc2104-2-i','xcvu125-flvc2104-3-e','xcvu125-flvd1517-1-i','xcvu125-flvd1517-1H-e','xcvu125-flvd1517-1HV-e','xcvu125-flvd1517-2-e','xcvu125-flvd1517-2-i','xcvu125-flvd1517-3-e','xcvu125_CIV-flva2104-1-i','xcvu125_CIV-flva2104-1H-e','xcvu125_CIV-flva2104-1HV-e','xcvu125_CIV-flva2104-2-e','xcvu125_CIV-flva2104-2-i','xcvu125_CIV-flva2104-3-e','xcvu125_CIV-flvb1760-1-i','xcvu125_CIV-flvb1760-1H-e','xcvu125_CIV-flvb1760-1HV-e','xcvu125_CIV-flvb1760-2-e','xcvu125_CIV-flvb1760-2-i','xcvu125_CIV-flvb1760-3-e','xcvu125_CIV-flvb2104-1-i','xcvu125_CIV-flvb2104-1H-e','xcvu125_CIV-flvb2104-1HV-e','xcvu125_CIV-flvb2104-2-e','xcvu125_CIV-flvb2104-2-i','xcvu125_CIV-flvb2104-3-e','xcvu125_CIV-flvc2104-1-i','xcvu125_CIV-flvc2104-1H-e','xcvu125_CIV-flvc2104-1HV-e','xcvu125_CIV-flvc2104-2-e','xcvu125_CIV-flvc2104-2-i','xcvu125_CIV-flvc2104-3-e','xcvu125_CIV-flvd1517-1-i','xcvu125_CIV-flvd1517-1H-e','xcvu125_CIV-flvd1517-1HV-e','xcvu125_CIV-flvd1517-2-e','xcvu125_CIV-flvd1517-2-i','xcvu125_CIV-flvd1517-3-e','xcvu160-flgb2104-1-i','xcvu160-flgb2104-1H-e','xcvu160-flgb2104-1HV-e','xcvu160-flgb2104-2-e','xcvu160-flgb2104-2-i','xcvu160-flgb2104-3-e','xcvu160-flgc2104-1-i','xcvu160-flgc2104-1H-e','xcvu160-flgc2104-1HV-e','xcvu160-flgc2104-2-e','xcvu160-flgc2104-2-i','xcvu160-flgc2104-3-e','xcvu160_CIV-flgb2104-1-i','xcvu160_CIV-flgb2104-1H-e','xcvu160_CIV-flgb2104-1HV-e','xcvu160_CIV-flgb2104-2-e','xcvu160_CIV-flgb2104-2-i','xcvu160_CIV-flgb2104-3-e','xcvu160_CIV-flgc2104-1-i','xcvu160_CIV-flgc2104-1H-e','xcvu160_CIV-flgc2104-1HV-e','xcvu160_CIV-flgc2104-2-e','xcvu160_CIV-flgc2104-2-i','xcvu160_CIV-flgc2104-3-e','xcvu190-flga2577-1-i','xcvu190-flga2577-1H-e','xcvu190-flga2577-1HV-e','xcvu190-flga2577-2-e','xcvu190-flga2577-2-i','xcvu190-flga2577-3-e','xcvu190-flgb2104-1-i','xcvu190-flgb2104-1H-e','xcvu190-flgb2104-1HV-e','xcvu190-flgb2104-2-e','xcvu190-flgb2104-2-i','xcvu190-flgb2104-3-e','xcvu190-flgc2104-1-i','xcvu190-flgc2104-1H-e','xcvu190-flgc2104-1HV-e','xcvu190-flgc2104-2-e','xcvu190-flgc2104-2-i','xcvu190-flgc2104-3-e','xcvu440-flga2892-1-c','xcvu440-flga2892-1-i','xcvu440-flga2892-2-e','xcvu440-flga2892-2-i','xcvu440-flga2892-3-e','xcvu440-flgb2377-1-c','xcvu440-flgb2377-1-i','xcvu440-flgb2377-2-e','xcvu440-flgb2377-2-i','xcvu440-flgb2377-3-e','xcvu440_CIV-flga2892-1-c','xcvu440_CIV-flga2892-1-i','xcvu440_CIV-flga2892-2-e','xcvu440_CIV-flga2892-2-i','xcvu440_CIV-flga2892-3-e','xcvu440_CIV-flgb2377-1-c','xcvu440_CIV-flgb2377-1-i','xcvu440_CIV-flgb2377-2-e','xcvu440_CIV-flgb2377-2-i','xcvu440_CIV-flgb2377-3-e',};
        else
            r={''};
        end
    elseif idx==9
        if nargin==1
            r={'xc7z007s','xc7z010','xc7z010i','xc7z012s','xc7z014s','xc7z015','xc7z015i','xc7z020','xc7z020i','xc7z030','xc7z030i','xc7z035','xc7z035i','xc7z045','xc7z045i','xc7z100','xc7z100i',};
        elseif nargin==3
            if strcmpi(varargin{1},'xc7z007s')
                if strcmpi(varargin{2},'package')
                    r={'clg225','clg400',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2',};
                end
            elseif strcmpi(varargin{1},'xc7z010')
                if strcmpi(varargin{2},'package')
                    r={'clg225','clg400',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z010i')
                if strcmpi(varargin{2},'package')
                    r={'clg225','clg400',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7z012s')
                if strcmpi(varargin{2},'package')
                    r={'clg485',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2',};
                end
            elseif strcmpi(varargin{1},'xc7z014s')
                if strcmpi(varargin{2},'package')
                    r={'clg400','clg484',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2',};
                end
            elseif strcmpi(varargin{1},'xc7z015')
                if strcmpi(varargin{2},'package')
                    r={'clg485',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z015i')
                if strcmpi(varargin{2},'package')
                    r={'clg485',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7z020')
                if strcmpi(varargin{2},'package')
                    r={'clg400','clg484',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z020i')
                if strcmpi(varargin{2},'package')
                    r={'clg400','clg484',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1L',};
                end
            elseif strcmpi(varargin{1},'xc7z030')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg676','ffv676','sbg485','sbv485',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z030i')
                if strcmpi(varargin{2},'package')
                    r={'fbg484','fbg676','fbv484','fbv676','ffg676','ffv676','sbg485','sbv485',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7z035')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbv676','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z035i')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbv676','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7z045')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbv676','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2','-3',};
                end
            elseif strcmpi(varargin{1},'xc7z045i')
                if strcmpi(varargin{2},'package')
                    r={'fbg676','fbv676','ffg676','ffg900','ffv676','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            elseif strcmpi(varargin{1},'xc7z100')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg900','ffv1156','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-1','-2',};
                end
            elseif strcmpi(varargin{1},'xc7z100i')
                if strcmpi(varargin{2},'package')
                    r={'ffg1156','ffg900','ffv1156','ffv900',};
                elseif strcmpi(varargin{2},'speed')
                    r={'-2L',};
                end
            end
        end
    elseif idx==10
        if nargin==1
            r={'xcu25-ffvc1760-2L-e','xcu25-ffvc1760-2LV-e','xcu30-fbvb900-2-e','xczu11eg-ffvb1517-1-e','xczu11eg-ffvb1517-1-i','xczu11eg-ffvb1517-1L-i','xczu11eg-ffvb1517-1LV-i','xczu11eg-ffvb1517-2-e','xczu11eg-ffvb1517-2-i','xczu11eg-ffvb1517-2L-e','xczu11eg-ffvb1517-2LV-e','xczu11eg-ffvb1517-3-e','xczu11eg-ffvc1156-1-e','xczu11eg-ffvc1156-1-i','xczu11eg-ffvc1156-1L-i','xczu11eg-ffvc1156-1LV-i','xczu11eg-ffvc1156-2-e','xczu11eg-ffvc1156-2-i','xczu11eg-ffvc1156-2L-e','xczu11eg-ffvc1156-2LV-e','xczu11eg-ffvc1156-3-e','xczu11eg-ffvc1760-1-e','xczu11eg-ffvc1760-1-i','xczu11eg-ffvc1760-1L-i','xczu11eg-ffvc1760-1LV-i','xczu11eg-ffvc1760-2-e','xczu11eg-ffvc1760-2-i','xczu11eg-ffvc1760-2L-e','xczu11eg-ffvc1760-2LV-e','xczu11eg-ffvc1760-3-e','xczu11eg-ffvf1517-1-e','xczu11eg-ffvf1517-1-i','xczu11eg-ffvf1517-1L-i','xczu11eg-ffvf1517-1LV-i','xczu11eg-ffvf1517-2-e','xczu11eg-ffvf1517-2-i','xczu11eg-ffvf1517-2L-e','xczu11eg-ffvf1517-2LV-e','xczu11eg-ffvf1517-3-e','xczu15eg-ffvb1156-1-e','xczu15eg-ffvb1156-1-i','xczu15eg-ffvb1156-1L-i','xczu15eg-ffvb1156-1LV-i','xczu15eg-ffvb1156-2-e','xczu15eg-ffvb1156-2-i','xczu15eg-ffvb1156-2L-e','xczu15eg-ffvb1156-2LV-e','xczu15eg-ffvb1156-3-e','xczu15eg-ffvc900-1-e','xczu15eg-ffvc900-1-i','xczu15eg-ffvc900-1L-i','xczu15eg-ffvc900-1LV-i','xczu15eg-ffvc900-2-e','xczu15eg-ffvc900-2-i','xczu15eg-ffvc900-2L-e','xczu15eg-ffvc900-2LV-e','xczu15eg-ffvc900-3-e','xczu17eg-ffvb1517-1-e','xczu17eg-ffvb1517-1-i','xczu17eg-ffvb1517-1L-i','xczu17eg-ffvb1517-1LV-i','xczu17eg-ffvb1517-2-e','xczu17eg-ffvb1517-2-i','xczu17eg-ffvb1517-2L-e','xczu17eg-ffvb1517-2LV-e','xczu17eg-ffvb1517-3-e','xczu17eg-ffvc1760-1-e','xczu17eg-ffvc1760-1-i','xczu17eg-ffvc1760-1L-i','xczu17eg-ffvc1760-1LV-i','xczu17eg-ffvc1760-2-e','xczu17eg-ffvc1760-2-i','xczu17eg-ffvc1760-2L-e','xczu17eg-ffvc1760-2LV-e','xczu17eg-ffvc1760-3-e','xczu17eg-ffvd1760-1-e','xczu17eg-ffvd1760-1-i','xczu17eg-ffvd1760-1L-i','xczu17eg-ffvd1760-1LV-i','xczu17eg-ffvd1760-2-e','xczu17eg-ffvd1760-2-i','xczu17eg-ffvd1760-2L-e','xczu17eg-ffvd1760-2LV-e','xczu17eg-ffvd1760-3-e','xczu17eg-ffve1924-1-e','xczu17eg-ffve1924-1-i','xczu17eg-ffve1924-1L-i','xczu17eg-ffve1924-1LV-i','xczu17eg-ffve1924-2-e','xczu17eg-ffve1924-2-i','xczu17eg-ffve1924-2L-e','xczu17eg-ffve1924-2LV-e','xczu17eg-ffve1924-3-e','xczu19eg-ffvb1517-1-e','xczu19eg-ffvb1517-1-i','xczu19eg-ffvb1517-1L-i','xczu19eg-ffvb1517-1LV-i','xczu19eg-ffvb1517-2-e','xczu19eg-ffvb1517-2-i','xczu19eg-ffvb1517-2L-e','xczu19eg-ffvb1517-2LV-e','xczu19eg-ffvb1517-3-e','xczu19eg-ffvc1760-1-e','xczu19eg-ffvc1760-1-i','xczu19eg-ffvc1760-1L-i','xczu19eg-ffvc1760-1LV-i','xczu19eg-ffvc1760-2-e','xczu19eg-ffvc1760-2-i','xczu19eg-ffvc1760-2L-e','xczu19eg-ffvc1760-2LV-e','xczu19eg-ffvc1760-3-e','xczu19eg-ffvd1760-1-e','xczu19eg-ffvd1760-1-i','xczu19eg-ffvd1760-1L-i','xczu19eg-ffvd1760-1LV-i','xczu19eg-ffvd1760-2-e','xczu19eg-ffvd1760-2-i','xczu19eg-ffvd1760-2L-e','xczu19eg-ffvd1760-2LV-e','xczu19eg-ffvd1760-3-e','xczu19eg-ffve1924-1-e','xczu19eg-ffve1924-1-i','xczu19eg-ffve1924-1L-i','xczu19eg-ffve1924-1LV-i','xczu19eg-ffve1924-2-e','xczu19eg-ffve1924-2-i','xczu19eg-ffve1924-2L-e','xczu19eg-ffve1924-2LV-e','xczu19eg-ffve1924-3-e','xczu2cg-sbva484-1-e','xczu2cg-sbva484-1-i','xczu2cg-sbva484-1L-i','xczu2cg-sbva484-1LV-i','xczu2cg-sbva484-2-e','xczu2cg-sbva484-2-i','xczu2cg-sbva484-2L-e','xczu2cg-sbva484-2LV-e','xczu2cg-sfva625-1-e','xczu2cg-sfva625-1-i','xczu2cg-sfva625-1L-i','xczu2cg-sfva625-1LV-i','xczu2cg-sfva625-2-e','xczu2cg-sfva625-2-i','xczu2cg-sfva625-2L-e','xczu2cg-sfva625-2LV-e','xczu2cg-sfvc784-1-e','xczu2cg-sfvc784-1-i','xczu2cg-sfvc784-1L-i','xczu2cg-sfvc784-1LV-i','xczu2cg-sfvc784-2-e','xczu2cg-sfvc784-2-i','xczu2cg-sfvc784-2L-e','xczu2cg-sfvc784-2LV-e','xczu2eg-sbva484-1-e','xczu2eg-sbva484-1-i','xczu2eg-sbva484-1L-i','xczu2eg-sbva484-1LV-i','xczu2eg-sbva484-2-e','xczu2eg-sbva484-2-i','xczu2eg-sbva484-2L-e','xczu2eg-sbva484-2LV-e','xczu2eg-sfva625-1-e','xczu2eg-sfva625-1-i','xczu2eg-sfva625-1L-i','xczu2eg-sfva625-1LV-i','xczu2eg-sfva625-2-e','xczu2eg-sfva625-2-i','xczu2eg-sfva625-2L-e','xczu2eg-sfva625-2LV-e','xczu2eg-sfvc784-1-e','xczu2eg-sfvc784-1-i','xczu2eg-sfvc784-1L-i','xczu2eg-sfvc784-1LV-i','xczu2eg-sfvc784-2-e','xczu2eg-sfvc784-2-i','xczu2eg-sfvc784-2L-e','xczu2eg-sfvc784-2LV-e','xczu3cg-sbva484-1-e','xczu3cg-sbva484-1-i','xczu3cg-sbva484-1L-i','xczu3cg-sbva484-1LV-i','xczu3cg-sbva484-2-e','xczu3cg-sbva484-2-i','xczu3cg-sbva484-2L-e','xczu3cg-sbva484-2LV-e','xczu3cg-sfva625-1-e','xczu3cg-sfva625-1-i','xczu3cg-sfva625-1L-i','xczu3cg-sfva625-1LV-i','xczu3cg-sfva625-2-e','xczu3cg-sfva625-2-i','xczu3cg-sfva625-2L-e','xczu3cg-sfva625-2LV-e','xczu3cg-sfvc784-1-e','xczu3cg-sfvc784-1-i','xczu3cg-sfvc784-1L-i','xczu3cg-sfvc784-1LV-i','xczu3cg-sfvc784-2-e','xczu3cg-sfvc784-2-i','xczu3cg-sfvc784-2L-e','xczu3cg-sfvc784-2LV-e','xczu3eg-sbva484-1-e','xczu3eg-sbva484-1-i','xczu3eg-sbva484-1L-i','xczu3eg-sbva484-1LV-i','xczu3eg-sbva484-2-e','xczu3eg-sbva484-2-i','xczu3eg-sbva484-2L-e','xczu3eg-sbva484-2LV-e','xczu3eg-sfva625-1-e','xczu3eg-sfva625-1-i','xczu3eg-sfva625-1L-i','xczu3eg-sfva625-1LV-i','xczu3eg-sfva625-2-e','xczu3eg-sfva625-2-i','xczu3eg-sfva625-2L-e','xczu3eg-sfva625-2LV-e','xczu3eg-sfvc784-1-e','xczu3eg-sfvc784-1-i','xczu3eg-sfvc784-1L-i','xczu3eg-sfvc784-1LV-i','xczu3eg-sfvc784-2-e','xczu3eg-sfvc784-2-i','xczu3eg-sfvc784-2L-e','xczu3eg-sfvc784-2LV-e','xczu4cg-fbvb900-1-e','xczu4cg-fbvb900-1-i','xczu4cg-fbvb900-1L-i','xczu4cg-fbvb900-1LV-i','xczu4cg-fbvb900-2-e','xczu4cg-fbvb900-2-i','xczu4cg-fbvb900-2L-e','xczu4cg-fbvb900-2LV-e','xczu4cg-sfvc784-1-e','xczu4cg-sfvc784-1-i','xczu4cg-sfvc784-1L-i','xczu4cg-sfvc784-1LV-i','xczu4cg-sfvc784-2-e','xczu4cg-sfvc784-2-i','xczu4cg-sfvc784-2L-e','xczu4cg-sfvc784-2LV-e','xczu4eg-fbvb900-1-e','xczu4eg-fbvb900-1-i','xczu4eg-fbvb900-1L-i','xczu4eg-fbvb900-1LV-i','xczu4eg-fbvb900-2-e','xczu4eg-fbvb900-2-i','xczu4eg-fbvb900-2L-e','xczu4eg-fbvb900-2LV-e','xczu4eg-fbvb900-3-e','xczu4eg-sfvc784-1-e','xczu4eg-sfvc784-1-i','xczu4eg-sfvc784-1L-i','xczu4eg-sfvc784-1LV-i','xczu4eg-sfvc784-2-e','xczu4eg-sfvc784-2-i','xczu4eg-sfvc784-2L-e','xczu4eg-sfvc784-2LV-e','xczu4eg-sfvc784-3-e','xczu4ev-fbvb900-1-e','xczu4ev-fbvb900-1-i','xczu4ev-fbvb900-1L-i','xczu4ev-fbvb900-1LV-i','xczu4ev-fbvb900-2-e','xczu4ev-fbvb900-2-i','xczu4ev-fbvb900-2L-e','xczu4ev-fbvb900-2LV-e','xczu4ev-fbvb900-3-e','xczu4ev-sfvc784-1-e','xczu4ev-sfvc784-1-i','xczu4ev-sfvc784-1L-i','xczu4ev-sfvc784-1LV-i','xczu4ev-sfvc784-2-e','xczu4ev-sfvc784-2-i','xczu4ev-sfvc784-2L-e','xczu4ev-sfvc784-2LV-e','xczu4ev-sfvc784-3-e','xczu5cg-fbvb900-1-e','xczu5cg-fbvb900-1-i','xczu5cg-fbvb900-1L-i','xczu5cg-fbvb900-1LV-i','xczu5cg-fbvb900-2-e','xczu5cg-fbvb900-2-i','xczu5cg-fbvb900-2L-e','xczu5cg-fbvb900-2LV-e','xczu5cg-sfvc784-1-e','xczu5cg-sfvc784-1-i','xczu5cg-sfvc784-1L-i','xczu5cg-sfvc784-1LV-i','xczu5cg-sfvc784-2-e','xczu5cg-sfvc784-2-i','xczu5cg-sfvc784-2L-e','xczu5cg-sfvc784-2LV-e','xczu5eg-fbvb900-1-e','xczu5eg-fbvb900-1-i','xczu5eg-fbvb900-1L-i','xczu5eg-fbvb900-1LV-i','xczu5eg-fbvb900-2-e','xczu5eg-fbvb900-2-i','xczu5eg-fbvb900-2L-e','xczu5eg-fbvb900-2LV-e','xczu5eg-fbvb900-3-e','xczu5eg-sfvc784-1-e','xczu5eg-sfvc784-1-i','xczu5eg-sfvc784-1L-i','xczu5eg-sfvc784-1LV-i','xczu5eg-sfvc784-2-e','xczu5eg-sfvc784-2-i','xczu5eg-sfvc784-2L-e','xczu5eg-sfvc784-2LV-e','xczu5eg-sfvc784-3-e','xczu5ev-fbvb900-1-e','xczu5ev-fbvb900-1-i','xczu5ev-fbvb900-1L-i','xczu5ev-fbvb900-1LV-i','xczu5ev-fbvb900-2-e','xczu5ev-fbvb900-2-i','xczu5ev-fbvb900-2L-e','xczu5ev-fbvb900-2LV-e','xczu5ev-fbvb900-3-e','xczu5ev-sfvc784-1-e','xczu5ev-sfvc784-1-i','xczu5ev-sfvc784-1L-i','xczu5ev-sfvc784-1LV-i','xczu5ev-sfvc784-2-e','xczu5ev-sfvc784-2-i','xczu5ev-sfvc784-2L-e','xczu5ev-sfvc784-2LV-e','xczu5ev-sfvc784-3-e','xczu6cg-ffvb1156-1-e','xczu6cg-ffvb1156-1-i','xczu6cg-ffvb1156-1L-i','xczu6cg-ffvb1156-1LV-i','xczu6cg-ffvb1156-2-e','xczu6cg-ffvb1156-2-i','xczu6cg-ffvb1156-2L-e','xczu6cg-ffvb1156-2LV-e','xczu6cg-ffvc900-1-e','xczu6cg-ffvc900-1-i','xczu6cg-ffvc900-1L-i','xczu6cg-ffvc900-1LV-i','xczu6cg-ffvc900-2-e','xczu6cg-ffvc900-2-i','xczu6cg-ffvc900-2L-e','xczu6cg-ffvc900-2LV-e','xczu6eg-ffvb1156-1-e','xczu6eg-ffvb1156-1-i','xczu6eg-ffvb1156-1L-i','xczu6eg-ffvb1156-1LV-i','xczu6eg-ffvb1156-2-e','xczu6eg-ffvb1156-2-i','xczu6eg-ffvb1156-2L-e','xczu6eg-ffvb1156-2LV-e','xczu6eg-ffvb1156-3-e','xczu6eg-ffvc900-1-e','xczu6eg-ffvc900-1-i','xczu6eg-ffvc900-1L-i','xczu6eg-ffvc900-1LV-i','xczu6eg-ffvc900-2-e','xczu6eg-ffvc900-2-i','xczu6eg-ffvc900-2L-e','xczu6eg-ffvc900-2LV-e','xczu6eg-ffvc900-3-e','xczu7cg-fbvb900-1-e','xczu7cg-fbvb900-1-i','xczu7cg-fbvb900-1L-i','xczu7cg-fbvb900-1LV-i','xczu7cg-fbvb900-2-e','xczu7cg-fbvb900-2-i','xczu7cg-fbvb900-2L-e','xczu7cg-fbvb900-2LV-e','xczu7cg-ffvc1156-1-e','xczu7cg-ffvc1156-1-i','xczu7cg-ffvc1156-1L-i','xczu7cg-ffvc1156-1LV-i','xczu7cg-ffvc1156-2-e','xczu7cg-ffvc1156-2-i','xczu7cg-ffvc1156-2L-e','xczu7cg-ffvc1156-2LV-e','xczu7cg-ffvf1517-1-e','xczu7cg-ffvf1517-1-i','xczu7cg-ffvf1517-1L-i','xczu7cg-ffvf1517-1LV-i','xczu7cg-ffvf1517-2-e','xczu7cg-ffvf1517-2-i','xczu7cg-ffvf1517-2L-e','xczu7cg-ffvf1517-2LV-e','xczu7eg-fbvb900-1-e','xczu7eg-fbvb900-1-i','xczu7eg-fbvb900-1L-i','xczu7eg-fbvb900-1LV-i','xczu7eg-fbvb900-2-e','xczu7eg-fbvb900-2-i','xczu7eg-fbvb900-2L-e','xczu7eg-fbvb900-2LV-e','xczu7eg-fbvb900-3-e','xczu7eg-ffvc1156-1-e','xczu7eg-ffvc1156-1-i','xczu7eg-ffvc1156-1L-i','xczu7eg-ffvc1156-1LV-i','xczu7eg-ffvc1156-2-e','xczu7eg-ffvc1156-2-i','xczu7eg-ffvc1156-2L-e','xczu7eg-ffvc1156-2LV-e','xczu7eg-ffvc1156-3-e','xczu7eg-ffvf1517-1-e','xczu7eg-ffvf1517-1-i','xczu7eg-ffvf1517-1L-i','xczu7eg-ffvf1517-1LV-i','xczu7eg-ffvf1517-2-e','xczu7eg-ffvf1517-2-i','xczu7eg-ffvf1517-2L-e','xczu7eg-ffvf1517-2LV-e','xczu7eg-ffvf1517-3-e','xczu7ev-fbvb900-1-e','xczu7ev-fbvb900-1-i','xczu7ev-fbvb900-1L-i','xczu7ev-fbvb900-1LV-i','xczu7ev-fbvb900-2-e','xczu7ev-fbvb900-2-i','xczu7ev-fbvb900-2L-e','xczu7ev-fbvb900-2LV-e','xczu7ev-fbvb900-3-e','xczu7ev-ffvc1156-1-e','xczu7ev-ffvc1156-1-i','xczu7ev-ffvc1156-1L-i','xczu7ev-ffvc1156-1LV-i','xczu7ev-ffvc1156-2-e','xczu7ev-ffvc1156-2-i','xczu7ev-ffvc1156-2L-e','xczu7ev-ffvc1156-2LV-e','xczu7ev-ffvc1156-3-e','xczu7ev-ffvf1517-1-e','xczu7ev-ffvf1517-1-i','xczu7ev-ffvf1517-1L-i','xczu7ev-ffvf1517-1LV-i','xczu7ev-ffvf1517-2-e','xczu7ev-ffvf1517-2-i','xczu7ev-ffvf1517-2L-e','xczu7ev-ffvf1517-2LV-e','xczu7ev-ffvf1517-3-e','xczu9cg-ffvb1156-1-e','xczu9cg-ffvb1156-1-i','xczu9cg-ffvb1156-1L-i','xczu9cg-ffvb1156-1LV-i','xczu9cg-ffvb1156-2-e','xczu9cg-ffvb1156-2-i','xczu9cg-ffvb1156-2L-e','xczu9cg-ffvb1156-2LV-e','xczu9cg-ffvc900-1-e','xczu9cg-ffvc900-1-i','xczu9cg-ffvc900-1L-i','xczu9cg-ffvc900-1LV-i','xczu9cg-ffvc900-2-e','xczu9cg-ffvc900-2-i','xczu9cg-ffvc900-2L-e','xczu9cg-ffvc900-2LV-e','xczu9eg-ffvb1156-1-e','xczu9eg-ffvb1156-1-i','xczu9eg-ffvb1156-1L-i','xczu9eg-ffvb1156-1LV-i','xczu9eg-ffvb1156-2-e','xczu9eg-ffvb1156-2-i','xczu9eg-ffvb1156-2L-e','xczu9eg-ffvb1156-2LV-e','xczu9eg-ffvb1156-3-e','xczu9eg-ffvc900-1-e','xczu9eg-ffvc900-1-i','xczu9eg-ffvc900-1L-i','xczu9eg-ffvc900-1LV-i','xczu9eg-ffvc900-2-e','xczu9eg-ffvc900-2-i','xczu9eg-ffvc900-2L-e','xczu9eg-ffvc900-2LV-e','xczu9eg-ffvc900-3-e',};
        else
            r={''};
        end
    elseif idx==11
        if nargin==1
            r={'xczu21dr-ffvd1156-1-e','xczu21dr-ffvd1156-1-i','xczu21dr-ffvd1156-1L-i','xczu21dr-ffvd1156-1LV-i','xczu21dr-ffvd1156-2-e','xczu21dr-ffvd1156-2-i','xczu21dr-ffvd1156-2L-e','xczu21dr-ffvd1156-2LV-e','xczu21dr-ffvd1156-2LVI-i','xczu25dr-ffve1156-1-e','xczu25dr-ffve1156-1-i','xczu25dr-ffve1156-1L-i','xczu25dr-ffve1156-1LV-i','xczu25dr-ffve1156-2-e','xczu25dr-ffve1156-2-i','xczu25dr-ffve1156-2L-e','xczu25dr-ffve1156-2LV-e','xczu25dr-ffve1156-2LVI-i','xczu25dr-ffvg1517-1-e','xczu25dr-ffvg1517-1-i','xczu25dr-ffvg1517-1L-i','xczu25dr-ffvg1517-1LV-i','xczu25dr-ffvg1517-2-e','xczu25dr-ffvg1517-2-i','xczu25dr-ffvg1517-2L-e','xczu25dr-ffvg1517-2LV-e','xczu25dr-ffvg1517-2LVI-i','xczu25dr-fsve1156-1-e','xczu25dr-fsve1156-1-i','xczu25dr-fsve1156-1L-i','xczu25dr-fsve1156-1LV-i','xczu25dr-fsve1156-2-e','xczu25dr-fsve1156-2-i','xczu25dr-fsve1156-2L-e','xczu25dr-fsve1156-2LV-e','xczu25dr-fsve1156-2LVI-i','xczu25dr-fsvg1517-1-e','xczu25dr-fsvg1517-1-i','xczu25dr-fsvg1517-1L-i','xczu25dr-fsvg1517-1LV-i','xczu25dr-fsvg1517-2-e','xczu25dr-fsvg1517-2-i','xczu25dr-fsvg1517-2L-e','xczu25dr-fsvg1517-2LV-e','xczu25dr-fsvg1517-2LVI-i','xczu27dr-ffve1156-1-e','xczu27dr-ffve1156-1-i','xczu27dr-ffve1156-1L-i','xczu27dr-ffve1156-1LV-i','xczu27dr-ffve1156-2-e','xczu27dr-ffve1156-2-i','xczu27dr-ffve1156-2L-e','xczu27dr-ffve1156-2LV-e','xczu27dr-ffve1156-2LVI-i','xczu27dr-ffvg1517-1-e','xczu27dr-ffvg1517-1-i','xczu27dr-ffvg1517-1L-i','xczu27dr-ffvg1517-1LV-i','xczu27dr-ffvg1517-2-e','xczu27dr-ffvg1517-2-i','xczu27dr-ffvg1517-2L-e','xczu27dr-ffvg1517-2LV-e','xczu27dr-ffvg1517-2LVI-i','xczu27dr-fsve1156-1-e','xczu27dr-fsve1156-1-i','xczu27dr-fsve1156-1L-i','xczu27dr-fsve1156-1LV-i','xczu27dr-fsve1156-2-e','xczu27dr-fsve1156-2-i','xczu27dr-fsve1156-2L-e','xczu27dr-fsve1156-2LV-e','xczu27dr-fsve1156-2LVI-i','xczu27dr-fsvg1517-1-e','xczu27dr-fsvg1517-1-i','xczu27dr-fsvg1517-1L-i','xczu27dr-fsvg1517-1LV-i','xczu27dr-fsvg1517-2-e','xczu27dr-fsvg1517-2-i','xczu27dr-fsvg1517-2L-e','xczu27dr-fsvg1517-2LV-e','xczu27dr-fsvg1517-2LVI-i','xczu28dr-ffve1156-1-e','xczu28dr-ffve1156-1-i','xczu28dr-ffve1156-1L-i','xczu28dr-ffve1156-1LV-i','xczu28dr-ffve1156-2-e','xczu28dr-ffve1156-2-i','xczu28dr-ffve1156-2L-e','xczu28dr-ffve1156-2LV-e','xczu28dr-ffve1156-2LVI-i','xczu28dr-ffvg1517-1-e','xczu28dr-ffvg1517-1-i','xczu28dr-ffvg1517-1L-i','xczu28dr-ffvg1517-1LV-i','xczu28dr-ffvg1517-2-e','xczu28dr-ffvg1517-2-i','xczu28dr-ffvg1517-2L-e','xczu28dr-ffvg1517-2LV-e','xczu28dr-ffvg1517-2LVI-i','xczu28dr-fsve1156-1-e','xczu28dr-fsve1156-1-i','xczu28dr-fsve1156-1L-i','xczu28dr-fsve1156-1LV-i','xczu28dr-fsve1156-2-e','xczu28dr-fsve1156-2-i','xczu28dr-fsve1156-2L-e','xczu28dr-fsve1156-2LV-e','xczu28dr-fsve1156-2LVI-i','xczu28dr-fsvg1517-1-e','xczu28dr-fsvg1517-1-i','xczu28dr-fsvg1517-1L-i','xczu28dr-fsvg1517-1LV-i','xczu28dr-fsvg1517-2-e','xczu28dr-fsvg1517-2-i','xczu28dr-fsvg1517-2L-e','xczu28dr-fsvg1517-2LV-e','xczu28dr-fsvg1517-2LVI-i','xczu29dr-ffvf1760-1-e','xczu29dr-ffvf1760-1-i','xczu29dr-ffvf1760-1L-i','xczu29dr-ffvf1760-1LV-i','xczu29dr-ffvf1760-2-e','xczu29dr-ffvf1760-2-i','xczu29dr-ffvf1760-2L-e','xczu29dr-ffvf1760-2LV-e','xczu29dr-ffvf1760-2LVI-i','xczu29dr-fsvf1760-1-e','xczu29dr-fsvf1760-1-i','xczu29dr-fsvf1760-1L-i','xczu29dr-fsvf1760-1LV-i','xczu29dr-fsvf1760-2-e','xczu29dr-fsvf1760-2-i','xczu29dr-fsvf1760-2L-e','xczu29dr-fsvf1760-2LV-e','xczu29dr-fsvf1760-2LVI-i','xczu39dr-ffvf1760-2-i','xczu39dr-ffvf1760-2LVI-i','xczu39dr-fsvf1760-2-i','xczu39dr-fsvf1760-2LVI-i','xczu43dr-ffve1156-1-e','xczu43dr-ffve1156-1-i','xczu43dr-ffve1156-1LV-i','xczu43dr-ffve1156-2-e','xczu43dr-ffve1156-2-i','xczu43dr-ffve1156-2LVI-i','xczu43dr-ffvg1517-1-e','xczu43dr-ffvg1517-1-i','xczu43dr-ffvg1517-1LV-i','xczu43dr-ffvg1517-2-e','xczu43dr-ffvg1517-2-i','xczu43dr-ffvg1517-2LVI-i','xczu43dr-fsve1156-1-e','xczu43dr-fsve1156-1-i','xczu43dr-fsve1156-1LV-i','xczu43dr-fsve1156-2-e','xczu43dr-fsve1156-2-i','xczu43dr-fsve1156-2LVI-i','xczu43dr-fsvg1517-1-e','xczu43dr-fsvg1517-1-i','xczu43dr-fsvg1517-1LV-i','xczu43dr-fsvg1517-2-e','xczu43dr-fsvg1517-2-i','xczu43dr-fsvg1517-2LVI-i','xczu46dr-ffvh1760-1-e','xczu46dr-ffvh1760-1-i','xczu46dr-ffvh1760-1LV-i','xczu46dr-ffvh1760-2-e','xczu46dr-ffvh1760-2-i','xczu46dr-ffvh1760-2LVI-i','xczu46dr-fsvh1760-1-e','xczu46dr-fsvh1760-1-i','xczu46dr-fsvh1760-1LV-i','xczu46dr-fsvh1760-2-e','xczu46dr-fsvh1760-2-i','xczu46dr-fsvh1760-2LVI-i','xczu47dr-ffve1156-1-e','xczu47dr-ffve1156-1-i','xczu47dr-ffve1156-1LV-i','xczu47dr-ffve1156-2-e','xczu47dr-ffve1156-2-i','xczu47dr-ffve1156-2LVI-i','xczu47dr-ffvg1517-1-e','xczu47dr-ffvg1517-1-i','xczu47dr-ffvg1517-1LV-i','xczu47dr-ffvg1517-2-e','xczu47dr-ffvg1517-2-i','xczu47dr-ffvg1517-2LVI-i','xczu47dr-fsve1156-1-e','xczu47dr-fsve1156-1-i','xczu47dr-fsve1156-1LV-i','xczu47dr-fsve1156-2-e','xczu47dr-fsve1156-2-i','xczu47dr-fsve1156-2LVI-i','xczu47dr-fsvg1517-1-e','xczu47dr-fsvg1517-1-i','xczu47dr-fsvg1517-1LV-i','xczu47dr-fsvg1517-2-e','xczu47dr-fsvg1517-2-i','xczu47dr-fsvg1517-2LVI-i','xczu48dr-ffve1156-1-e','xczu48dr-ffve1156-1-i','xczu48dr-ffve1156-1LV-i','xczu48dr-ffve1156-2-e','xczu48dr-ffve1156-2-i','xczu48dr-ffve1156-2LVI-i','xczu48dr-ffvg1517-1-e','xczu48dr-ffvg1517-1-i','xczu48dr-ffvg1517-1LV-i','xczu48dr-ffvg1517-2-e','xczu48dr-ffvg1517-2-i','xczu48dr-ffvg1517-2LVI-i','xczu48dr-fsve1156-1-e','xczu48dr-fsve1156-1-i','xczu48dr-fsve1156-1LV-i','xczu48dr-fsve1156-2-e','xczu48dr-fsve1156-2-i','xczu48dr-fsve1156-2LVI-i','xczu48dr-fsvg1517-1-e','xczu48dr-fsvg1517-1-i','xczu48dr-fsvg1517-1LV-i','xczu48dr-fsvg1517-2-e','xczu48dr-fsvg1517-2-i','xczu48dr-fsvg1517-2LVI-i','xczu49dr-ffvf1760-1-e','xczu49dr-ffvf1760-1-i','xczu49dr-ffvf1760-1LV-i','xczu49dr-ffvf1760-2-e','xczu49dr-ffvf1760-2-e-es1','xczu49dr-ffvf1760-2-i','xczu49dr-ffvf1760-2LVI-i','xczu49dr-fsvf1760-1-e','xczu49dr-fsvf1760-1-i','xczu49dr-fsvf1760-1LV-i','xczu49dr-fsvf1760-2-e','xczu49dr-fsvf1760-2-i','xczu49dr-fsvf1760-2LVI-i',};
        else
            r={''};
        end
    end
end
