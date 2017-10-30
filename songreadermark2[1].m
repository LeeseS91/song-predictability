% function songreader(file)
clear all
file='chorus';
filename=[file '.txt'];
song=load(filename);
% song=textformat;
showsong=0;
for N=12 % max length of string examined
    
    error=0;
    playsong=0;
    
    ptime=0.1; % speed of playback
    nmark=0;
    jjmark=0;
    % import sound
    [sound playrate] = wavread('click.wav');
    click = audioplayer(sound, playrate);
    % play song
    if playsong==1;
        for i=1:length(song);
            if song(i)==1
                play(click)
                pause(ptime)
            else
                pause(ptime);
            end
        end
    end
    
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
    
    predict(1)=randi(2)-1;
    equalcount=0;
    
    for j=1:(length(song)-1);
        for n=1:N
            if j>=n
                for jj=1:size(cell_pattern{n},1)
                    if song(j-(n-1):j)==cell_pattern{n,1}(jj,:)
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
                
                
                for f=1:size(cell_count{n},1)
                    if cell_count{n}(f,1)+cell_count{n}(f,2)~=0
                        cell_probs{n}(f,1)=cell_count{n}(f,1)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                        cell_probs{n}(f,2)=cell_count{n}(f,2)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                    end
                end
                cell_entropy=calcentropy(cell_probs,N);
                if nmark~=0
                    if n<N
                        %                 if n==1
                        %                     jjmark=1;
                        %                 end
                        probsarray(n,:)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark))*cell_probs{n+1}(jjmark, :);
                        %               (2^(n-1))*(1-cell_entropy{n}(jjmark/2+x))
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
            predict(j+1)=randi(2)-1;
            equalcount=equalcount+1;
            equalcountindex(equalcount)=j;
        elseif maxprob==1;
            predict(j+1)=0;
        elseif maxprob==2
            predict(j+1)=1;
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
    
    predict;
    conf=confusionmat(predict, song);
    score(N,1)=1-((conf(1,2)+conf(2,1))/sum(sum(conf)));
    score(N,2)=equalcount;
    
    if showsong==1
        comparmat(1,:)=strrep(num2str(song),' ','');
        comparmat(2,:)=strrep(num2str(predict),' ','');
        
        customshowalign(comparmat);
    end
    %     clear cell*
    %     clear p*
    %     clear n*
    %     clear j*
    %     clear e*
    %     clear c*
end

