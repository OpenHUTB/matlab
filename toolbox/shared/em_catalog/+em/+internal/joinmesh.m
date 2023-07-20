function[P,t]=joinmesh(p1,t1,p2,t2,varargin)



















    nameOfFunction='joinmesh';


    if isempty(p1)&&isempty(t1)
        P=p2;
        t=t2;



    elseif all(size(p1)==size(p2))&&all(p1==p2,"all")


        P=p1;
        t=[t1,t2];
    else
        tcol=3;
        meshptconsistencycheck=true;
        if~isempty(varargin)
            joinChoice=validatestring(varargin{1},{'Tri','Tet'});
            if strcmpi(joinChoice,'Tet')
                tcol=4;
            end
            if numel(varargin)==2
                meshptconsistencycheck=varargin{2};
            end
        end


        if iscell(p1)
            p1=cell2mat(p1);
            t1=cell2mat(t1);
        end





        validateattributes(p1,{'numeric'},{'nrows',3,'nonnan'},nameOfFunction,'Matrix of points, p1',1);
        validateattributes(p2,{'numeric'},{'nrows',3,'nonnan'},nameOfFunction,'Matrix of points, p2',3);
        validateattributes(t1,{'numeric'},{'nrows',4,'nonnan'},nameOfFunction,'Matrix of triangles, t1',2);
        validateattributes(t2,{'numeric'},{'nrows',4,'nonnan'},nameOfFunction,'Matrix of triangles, t2',4);



        if meshptconsistencycheck
            maxsizep1=max(size(p1));
            maxvalt1=max(t1(1:tcol,:),[],"all");
            if maxvalt1~=maxsizep1
                error(message('antenna:antennaerrors:InvalidValue','maximum triangle vertex index in t1',['= ',num2str(maxsizep1),' rather '],num2str(maxvalt1)));
            end
            maxsizep2=max(size(p2));
            maxvalt2=max(t2(1:tcol,:),[],"all");
            if maxvalt2~=maxsizep2
                error(message('antenna:antennaerrors:InvalidValue','maximum triangle vertex index in t2',['= ',num2str(maxsizep2),' rather '],num2str(maxvalt2)));
            end
        end


        P=[p1,p2];
        t2temp=t2(1:tcol,:)+size(p1,2);







        [~,ia]=uniquetol(P',1e-12,'ByRows',true,'DataScale',1,'OutputAllIndices',true);

        if~isempty(ia)&&any(cellfun(@numel,ia)>1)

            repeatgroups=ia(cellfun(@numel,ia)>1);
            repeatgroups=cell2mat(repeatgroups);

            if numel(repeatgroups)<4
                error(message('antenna:antennaerrors:FailureMeshGen'));
            end
            repeatgroups=[repeatgroups(1:2:end),repeatgroups(2:2:end)];

            [~,i]=sort(repeatgroups(:,2));
            rr=repeatgroups(i,:);

            P=P';
            P(rr(:,2),:)=[];
            P=P';

            for i=1:size(rr,1)
                t2temp(t2temp==rr(i,2))=rr(i,1);
                t2temp(t2temp>rr(i,2))=t2temp(t2temp>rr(i,2))-1;
                rr(:,2)=rr(:,2)-1;
            end
            t2(1:tcol,:)=t2temp;
            t=[t1,t2];
        else
            error(message('antenna:antennaerrors:FailureMeshGen'));
        end
    end
