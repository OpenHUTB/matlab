function diel=volumemesh(P,T,const)


    T=sort(T,1);
    [T,I]=sortrows(T');
    const.Epsilon_r=const.Epsilon_r(I);
    const.tan_delta=const.tan_delta(I);


    faceCodes=[1,2,3;1,2,4;1,3,4;2,3,4];



    faces1=T(:,faceCodes(1,:));
    faces2=T(:,faceCodes(2,:));
    faces3=T(:,faceCodes(3,:));
    faces4=T(:,faceCodes(4,:));


    ATlong=zeros(1,length(4*faces1));
    faces=zeros(length(4*faces1),3);
    for m=1:length(faces1)
        index=(m-1)*4+1:4*m;
        faces(index,:)=[faces1(m,:);faces2(m,:);faces3(m,:);faces4(m,:)];
        ATlong(index)=1*m;
    end
    [faces,I]=sortrows(faces);
    ATlong=ATlong(I);

    [faces,~,J]=unique(faces,'rows');
    faces=faces.';

    AT=zeros(2,length(faces));
    for i=1:size(ATlong,2)
        TetIndex=ATlong(i);
        ATIndex=J(i);
        if AT(1,ATIndex)==0
            AT(1,ATIndex)=TetIndex;
        elseif AT(2,ATIndex)==0
            AT(2,ATIndex)=TetIndex;
        end
    end
    AT=sort(AT);

    FacesB=faces(:,any(AT==0));
    ATB=AT(:,any(AT==0));
    FacesI=faces(:,all(AT~=0));
    ATI=AT(:,all(AT~=0));
    Faces=[FacesB,FacesI];
    AT=[ATB,ATI];





    FacesNontrivial=1:length(FacesB);
    for m=length(FacesB)+1:size(Faces,2)
        ContrastDiff=abs(const.Epsilon_r(AT(1,m))-const.Epsilon_r(AT(2,m)));
        if(ContrastDiff>0)
            FacesNontrivial=[FacesNontrivial,m];%#ok<AGROW>
        end
    end
    FacesB=Faces(:,FacesNontrivial);
    ATB=AT(:,FacesNontrivial);
    temp=setdiff(1:size(Faces,2),FacesNontrivial);
    FacesI=Faces(:,temp);
    ATI=AT(:,temp);
    Faces=[FacesB,FacesI];
    AT=[ATB,ATI];


    warnState=warning('Off','MATLAB:triangulation:PtsNotInTriWarnId');
    DT=triangulation(T,P.');
    warning(warnState);
    Edges=edges(DT);
    Edges=sortrows(Edges);

    diel=struct('T',T','Faces',Faces,'Edges',Edges','AT',AT,...
    'FacesNontrivial',length(FacesNontrivial));

end