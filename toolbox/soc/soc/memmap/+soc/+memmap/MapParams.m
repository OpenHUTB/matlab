classdef MapParams<matlab.mixin.Copyable
    properties(SetObservable)
type
name
baseAddr
range
path
regs
    end


    methods
        function this=MapParams(varargin)
            if nargin==4
                this.type=varargin{1};
                this.name=varargin{2};
                this.baseAddr=varargin{3};
                this.range=varargin{4};

            elseif nargin==5
                this.type=varargin{1};
                this.name=varargin{2};
                this.baseAddr=varargin{3};
                this.range=varargin{4};
                this.path=varargin{5};

            elseif nargin==6
                this.type=varargin{1};
                this.name=varargin{2};
                this.baseAddr=varargin{3};
                this.range=varargin{4};
                this.path=varargin{5};
                this.regs=varargin{6};
            end
        end
        function[isCompatible,isEqual]=compare(obj,other)
            minfo1={obj.type;obj.name;obj.range;obj.path}';
            minfo2={other.type;other.name;other.range;other.path}';
            isMemCompatible=isequal(minfo1,minfo2);
            isMemEqual=isMemCompatible&&...
            isequal(obj.baseAddr,other.baseAddr);

            if~isempty(obj.regs)&&~isempty(other.regs)
                rinfo1=sortrows({obj.regs.register;obj.regs.type;obj.regs.vectorlength;obj.regs.offset}');
                rinfo2=sortrows({other.regs.register;other.regs.type;other.regs.vectorlength;other.regs.offset}');
                isRegCompatible=isequal(rinfo1(:,1:3),rinfo2(:,1:3));
                isRegEqual=isRegCompatible&&...
                isequal(rinfo1(:,4),rinfo2(:,4));
            elseif(isempty(obj.regs)&&~isempty(other.regs))||...
                (~isempty(obj.regs)&&isempty(other.regs))


                isRegCompatible=false;
                isRegEqual=false;
            else
                isRegCompatible=true;
                isRegEqual=true;
            end

            isCompatible=isMemCompatible&&isRegCompatible;
            isEqual=isMemEqual&&isRegEqual;
        end


        function la=getLastAddress(obj)
            ba=l_hex2decAddr(obj.baseAddr);
            si=ceil(l_str2decRange(obj.range));
            la=ba+si;
        end


        function la=getLastRegAddress(obj,reg)
            REG_SIZE=4;
            if strcmp(reg.register,'HDL Coder registers')
                ast=hex2dec('00FC');
                asi=1;
            else
                ast=hex2dec(reg.offset(3:end));
                asi=eval(reg.vectorlength);
            end

            if asi==1
                la=ast+REG_SIZE-1;
            else
                la=ast+(pow2(ceil(log2(asi)))*REG_SIZE);
            end
        end


        function reconcile(obj,other)
            assert(isequal(obj.name,other.name)&&isequal(obj.type,other.type));

            obj.range=other.range;
            obj.path=other.path;
            if isempty(obj.regs)
                obj.regs=other.regs;
            else
                numEntries=length(obj.regs);
                toKeepInCurr=zeros([numEntries,1],'logical');
                highestAddress=0;
                for ii=1:numEntries
                    currReg=obj.regs(ii);
                    autoReg=findobj(other.regs,'register',currReg.register);
                    if~isempty(autoReg)
                        toKeepInCurr(ii)=true;
                        currReg.type=autoReg.type;
                        currReg.vectorlength=autoReg.vectorlength;
                        highestAddress=obj.trackHighestAddress(highestAddress,currReg);
                        obj.regs(ii)=currReg;
                    end
                end
                obj.regs=obj.regs(toKeepInCurr);
                numEntries=length(other.regs);
                for ii=1:numEntries
                    autoReg=other.regs(ii);
                    currReg=findobj(obj.regs,'register',autoReg.register);
                    if isempty(currReg)

                        newEntry=autoReg;
                        newEntry.offset=['0x',dec2hex(obj.calcNextAlignedRegAddress(highestAddress),4)];
                        highestAddress=obj.trackHighestAddress(highestAddress,newEntry);
                        obj.regs=[obj.regs;newEntry];
                    end
                end
            end
        end


        function ha=trackHighestAddress(obj,ha,currReg)
            la=obj.getLastRegAddress(currReg);
            if la>ha
                ha=la;
            end
        end


        function alignedAddress=calcNextAlignedRegAddress(obj,lastAddr)
            alignVal=4;
            alignedAddress=ceil((lastAddr+1)/alignVal)*alignVal;
        end

    end

end


function hexAddr=l_dec2hexAddr(decAddr)
    hexAddr=['0x',dec2hex(decAddr,8)];
end

function decAddr=l_hex2decAddr(hexAddr)
    decAddr=uint64(hex2dec(hexAddr));
end


function decRange=l_str2decRange(strRange)
    switch strRange{2}
    case ''
        mult=uint64(1);
    case 'K'
        mult=uint64(1024);
    case 'M'
        mult=uint64(1024*1024);
    case 'G'
        mult=uint64(1024*1024*1024);
    case 'T'
        mult=uint64(1024*1024*1024*1024);
    otherwise
        mult=uint64(1);
    end
    decRange=uint64(str2double(strRange{1})*mult);
end


