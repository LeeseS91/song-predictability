% function songreader(file)
clear all
% file='chorus';
% filename=[file '.txt'];
songstrct=load('binaryopus1.mat');
song=songstrct.textformat;
NN=2;
barsize=4;

error=0;
N=8;
ptime=0.1; % speed of playback
nmark=0;
jjmark=0;
equalcount=0;
equalindex=0;

cell_count = cell(N-1,1);
cell_pattern = cell(N,2);
cell_probs = cell(N-1,1);
for nn=1:N
    
    cell_pattern{nn,1}=de2bi(0:((NN^nn)-1),nn,NN);
    cell_pattern{nn,2}= zeros(length(cell_pattern{nn,1}),1);
    if nn==1
        cell_count{nn}=zeros(1,NN);
        cell_probs{nn}=ones(1,NN)*(1/NN);
    else
        cell_count{nn}=zeros(NN^(nn-1),NN);
        cell_probs{nn}=ones(NN^(nn-1),NN)*(1/NN);
    end
end
barcount=0;
predict(1)=randi(NN)-1;
equalcount=0;

for j=1:(length(song)-1);
    if j>=barsize
        if rem(j,barsize)==0;
            tempbarpattern=song(j-3:j);
            if barcount==0
                bar_pattern{1}(1,:)=tempbarpattern;
                bar_pattern{2}(1)=1;
                barcount=barcount+2;
            else
                if sum(ismember(bar_pattern(:,1:barsize), tempbarpattern,'rows'))==1
                    barindex=find(ismember(bar_pattern(:,1:barsize), tempbarpattern,'rows')==1);
                    bar_pattern{2}(barindex)=bar_pattern{2}(barindex)+1;
                else
                    bar_pattern{1}(barcount,:)=tempbarpattern;
                    bar_pattern{2}(barcount)=1;
                    barcount=barcount+1;
                end
            end
        end
    end
    clear barindex
    clear tempbarpattern
    
    
    for n=1:N
        if j>=n
            [song, cell_pattern, cell_count, cell_probs, jjmark,nmark,jjval]...
                =datacollectbar(j,n,NN,N, cell_pattern, song, cell_count,cell_probs);
            
            cell_entropy=calcentropy2(cell_probs,N,NN);
            if nmark~=0
                if n<N
                    probsarray(n,:)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark))*cell_probs{n+1}(jjmark, :);
                end
                jjmark=0;
                nmark=0;
                
            end
        end
    end
    if size(probsarray,1)==1
        maxprob=find(probsarray==max(probsarray));
    else
        newprobs=sum(probsarray);
        maxprob=find(newprobs==max(newprobs));
    end
    
    if size(maxprob,2)>1
        choice=randi(size(maxprob,2));
        predict(j+1)=maxprob(choice)-1;
        equalcount=equalcount+1;
        equalindex(equalcount)=j+1;
    else
        predict(j+1)=maxprob-1;
    end
    
    if predict(j+1)~=song(j+1)
        error=error+1;
        errorindex(error)=j+1;
    end
    clear probsindex
    clear probsarray
    clear maxindex
    clear index
    clear maxprob
    clear probmin
    clear probmax
    
    
end

% predict;
% % conf=confusionmat(predict, song);
% score(N,1)=1-((conf(1,2)+conf(2,1))/sum(sum(conf)));
% score(N,2)=equalcount;
%
% if showsong==1
%     comparmat(1,:)=strrep(num2str(song),' ','');
%     comparmat(2,:)=strrep(num2str(predict),' ','');
%
%     customshowalign(comparmat);
% end
%
% y(1,:)=strrep(num2str(song),' ','');
% if isempty(errorindex)==0
%     y(2,errorindex)='|';
%     altpeice=predict;
%     if isempty(equalindex)==0
%         y(3,equalindex)=':';
%         y(4,:)=strrep(num2str(altpeice),' ','');
%     else
%         y(3,:)=strrep(num2str(altpeice),' ','');
%     end
% end
%
% %     clear cell*
% %     clear p*
% %     clear n*
% %     clear j*
% %     clear e*
% %     clear c*
%
%

