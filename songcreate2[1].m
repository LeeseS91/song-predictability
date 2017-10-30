clear all
% establish users preferences as to how model is initialised and as to
% type of threshold used for the predictability.
random=str2double(inputdlg('0=chosen file as intro, 1=random intro sequence', 'Intro type',1,{'1'}));
if random==0
    introfile=inputdlg('Input file name (DONT INCLUDE FILE EXTENSION)', 'Filename',1,{'intro'});
else
    random=1;
end

prompt={'What type of threshold would you like to use? 1=meanlim, 2=normalised, 3=manual'};
defaultans={'2'};
input=str2double(inputdlg(prompt, 'Type of threshold',1,defaultans));
if input==1
    meanlim=1; normalise=0;
elseif input==2
    meanlim=0; normalise=1;
    predictability=str2double(inputdlg('What level of predictability would you like? (between 1 and 10)','Predictability',1,{'8'}));
elseif input==3
    meanlim=0; normalise=0;
    thresh=str2double(inputdlg('What threshold would you like to use?','Threshold',1,{'16'}));
else
    meanlim=1; normalise=0;
end
% normalise=1; % define whether normalised score should be used. 1 or 0
% % if normalise=0...
% thresh=16; % manualy define a threshold
% % if normailise=1...
% predictability=8; % if not defining your own threshold, give a level of predictability out of 10.

% initialise data
N=5; % max length of pattern analysed
MAX=100; %length of prediction
t=6;
l=6; % length of random generated sequence before starting the song creation
start=0;
startind=0;
calc=0;

count=0;
change=0;
changeindex=[];
equalindex=[];
maxpred=0;
if normalise==0
    threshold=thresh;
elseif normalise==1
    for pp=1:N-1
        maxpred=maxpred+2^(pp-1);
    end
    threshold=(predictability/10)*maxpred;
end

% suprisefact=10;
equalcount=0;
x=0;
% initialise the song and probability matricesM=10;
if random==1;
    M=l;
    intro=randi(2,[1 M])-1;
else
    introname=[introfile{1} '.txt'];
    intro=load(introname);
    M=length(intro);
end

initcell_pattern = cell(N,2);
cell_count = cell(N-1,1);
cell_pattern = cell(N,2);
cell_probs = cell(N-1,1);
for nn=1:N
    if nn==1
        n2m=[0;1];
    else
        pattern=dec2bin(0:((2^nn)-1));
        for r=1:2^nn
            for c=1:nn
                n2m(r,c)=str2num(pattern(r,c));
            end
        end
    end
    cell_pattern{nn,1}= n2m;
    cell_pattern{nn,2}= zeros(length(n2m),1);
    initcell_pattern{nn,1}= n2m;
    initcell_pattern{nn,2}= zeros(length(n2m),1);
    if nn==1
        cell_count{nn}=zeros(1,2);
        cell_probs{nn}=ones(1,2)*0.5;
    else
        cell_count{nn}=zeros(2^(nn-1),2);
        cell_probs{nn}=ones(2^(nn-1),2)*0.5;
    end
    clear n2m
    clear pattern
end

%initialise random song of length M
peice(1:length(intro))=intro;

for j=1:(length(peice));
    for n=1:N
        if j>=n
            for jj=1:size(initcell_pattern{n},1)
                if peice(j-(n-1):j)==initcell_pattern{n,1}(jj,:)
                    initcell_pattern{n,2}(jj)=initcell_pattern{n,2}(jj)+1;
                end
            end
        end
    end
end
j=1;
% section to work out probabilities/counts
while j<=M+MAX-1;
    % tally the occurence of each pattern found up to
    % the j value
    %     j=j+start;
    %     if j>M+MAX-1;
    %         break
    %     end
    
    
    if calc==1
        cap=j;
        j=j-6;
        while j<cap
            for n=1:N
                if j>=n && j<=M+MAX-n
                    for jj=1:size(cell_pattern{n},1)
                        if peice(j-(n-1):j)==cell_pattern{n,1}(jj,:)
                            cell_pattern{n,2}(jj)=cell_pattern{n,2}(jj)+1;
                            jjmark=jj;
                            if rem(jjmark/2,1)~=0
                                x=0.5;
                                nmark=1;
                            else
                                x=0;
                                nmark=2;
                            end
                            cell_count{n}((jjmark/2)+x,nmark)=cell_count{n}((jjmark/2)+x,nmark)+1;
                        end
                    end
                    % update probabilities with new cell counts
                    for f=1:size(cell_count{n},1)
                        if cell_count{n}(f,1)+cell_count{n}(f,2)~=0
                            cell_probs{n}(f,1)=cell_count{n}(f,1)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                            cell_probs{n}(f,2)=cell_count{n}(f,2)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                        end
                    end
                end
                cell_entropy=calcentropy(cell_probs,N);
                
                if j<M
                    if n<N
                        if jjmark~=0
                            initscoreent(j,n)=(2^(n-1))*(1-cell_entropy{n}(jjmark/2+x));
                        end
                    end
                end
                if j==M
                    for num=1:N-1
                        meaninitscore(num)=mean(initscoreent(num:M-1,num));
                    end
                    meaninitscore(N)=sum(meaninitscore(1:N-1));
                    % if specified earlier define the threshold as the mean limit worked
                    % out previously.
                    if meanlim==1
                        threshold=meaninitscore(N);
                    end
                end
                
                % want to create a probabililty array once j reaches end of
                % rand gen and calculate it using appropriate prob function
                % for the n value.
                %         if n>1
                if j>=M
                    if j==17
                        
                    end
                    if n<N
                        if jjmark~=0
                            scoreent(j-(M-1),n)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark));
                            %(2^(n-1))*
                            probsarray(n,:)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark))*cell_probs{n+1}(jjmark, :);
                            jjmark=0;
                            nmark=0;
                        end
                    end
                end
            end
            j=j+1;
        end
        calc=0;
    else
        for n=1:N
            if j>=n && j<=M+MAX-n
                for jj=1:size(cell_pattern{n},1)
                    if peice(j-(n-1):j)==cell_pattern{n,1}(jj,:)
                        cell_pattern{n,2}(jj)=cell_pattern{n,2}(jj)+1;
                        jjmark=jj;
                        if rem(jjmark/2,1)~=0
                            x=0.5;
                            nmark=1;
                        else
                            x=0;
                            nmark=2;
                        end
                        cell_count{n}((jjmark/2)+x,nmark)=cell_count{n}((jjmark/2)+x,nmark)+1;
                        break
                    end
                end
                % update probabilities with new cell counts
                for f=1:size(cell_count{n},1)
                    if cell_count{n}(f,1)+cell_count{n}(f,2)~=0
                        cell_probs{n}(f,1)=cell_count{n}(f,1)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                        cell_probs{n}(f,2)=cell_count{n}(f,2)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                    end
                end
            end
            cell_entropy=calcentropy(cell_probs,N);
            
            if j<M
                if n<N
                    if jjmark~=0
                        initscoreent(j,n)=(2^(n-1))*(1-cell_entropy{n}(jjmark/2+x));
                    end
                end
            end
            if j==M
                for num=1:N-1
                    meaninitscore(num)=mean(initscoreent(num:M-1,num));
                end
                meaninitscore(N)=sum(meaninitscore(1:N-1));
                % if specified earlier define the threshold as the mean limit worked
                % out previously.
                if meanlim==1
                    threshold=meaninitscore(N);
                end
            end
            
            % want to create a probabililty array once j reaches end of
            % rand gen and calculate it using appropriate prob function
            % for the n value.
            %         if n>1
            if j>=M
                if n<N
                    if jjmark~=0
                        scoreent(j-(M-1),n)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark));
                        %(2^(n-1))*
                        probsarray(n,:)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark))*cell_probs{n+1}(jjmark, :);
                        jjmark=0;
                        nmark=0;
                    end
                end
            end

        end
        if j>=M % as we dont want to start predicting before j reaches end of random gen
            
            scoreent(j-(M-1),N)=sum(scoreent(j-(M-1),:));
            count=count+1;
            
            if size(probsarray,1)==1
                maxprob=find(probsarray==max(probsarray));
            else
                format long
                newprobs=sum(probsarray);
                maxprob=find(newprobs==max(newprobs));
            end
            
            if rem(j-l,t)==0 && j>l
                tnum=t;
                % make predictions as to the next note in the peice
                if  mean(scoreent(j-(M-1)-tnum:j-(M-1),end))>threshold %suprise(count)<=initsuprisefact-1 %
                    change=change+1;
                    changeindex(change:change+t-1)=j+1:j+t;
                    change=change+t-1;
                    peice(j+1:j+t)=randi(2,[1,t])-1;
                    j=j+t-1;
                    startind=startind+1;
                    start=(startind*t)-(startind);
                    calc=1;
                else
                    if size(maxprob,2)>1
                        peice(j+1)=randi(2,1)-1;
                        equalcount=equalcount+1;
                        equalindex(equalcount)=j+1;
                    elseif maxprob==1;
                        peice(j+1)=0;
                    elseif maxprob==2
                        peice(j+1)=1;
                    end
                end
            else
                if size(maxprob,2)>1
                    peice(j+1)=randi(2,1)-1;
                    equalcount=equalcount+1;
                    equalindex(equalcount)=j+1;
                elseif maxprob==1;
                    peice(j+1)=0;
                elseif maxprob==2
                    peice(j+1)=1;
                    
                    
                end
                clear probsindex
                clear probsarray
                clear maxindex
                clear index
                clear maxprob
                clear probmin
                clear probmax
                
            end
            
        end
        j=j+1;
        
    end
end


y(1,:)=strrep(num2str(peice),' ','');
if isempty(changeindex)==0
    y(2,changeindex)='|';
    altpeice=peice;
    for ii=1:length(changeindex)
        if altpeice(changeindex(ii))==0
            altpeice(changeindex(ii))=1;
        elseif altpeice(changeindex(ii))==1
            altpeice(changeindex(ii))=0;
        end
    end
    if isempty(equalindex)==0
        y(3,equalindex)=':';
        y(4,:)=strrep(num2str(altpeice),' ','');
    else
        y(3,:)=strrep(num2str(altpeice),' ','');
    end
end



