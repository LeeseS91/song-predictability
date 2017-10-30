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
t=4;
l=2; % length of random generated sequence before starting the song creation
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
cell_entropy=calcentropy(cell_probs,N);



j=1;
% section to work out probabilities/counts
while j<=M+MAX-1;
    % tally the occurence of each pattern found up to
    % the j value
    
    if calc==1
        cap=j;
        j=cap-(t);
        while j<cap
            for n=1:N
                [cell_pattern, cell_count, cell_probs,cell_entropy, threshold, jjmark]...
                    = datacollect(j,peice, N, M, MAX, cell_pattern, cell_count, ...
                    cell_probs, cell_entropy, threshold, meanlim, n);
                
                
                if j>=M
                    if n<=N
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
            [cell_pattern, cell_count, cell_probs,cell_entropy, threshold, jjmark]...
                = datacollect(j,peice, N, M, MAX, cell_pattern, cell_count, ...
                cell_probs, cell_entropy, threshold, meanlim, n);
            
            % want to create a probabililty array once j reaches end of
            % rand gen and calculate it using appropriate prob function
            % for the n value.
            
            if j>=M
                if n<=N
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
    end
    if j>=M % as we dont want to start predicting before j reaches end of random gen
        
        [peice, scoreent, count, change, changeindex, ...
            equalcount, equalindex, calc, j] = prednext2(j, peice, scoreent, count, probsarray, t, change, ...
            changeindex, equalcount, equalindex, M, N, threshold);
        
        clear probsindex
        clear probsarray
        clear maxindex
        clear index
        clear maxprob
        clear probmin
        clear probmax
        
    end
    j=j+1;
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



