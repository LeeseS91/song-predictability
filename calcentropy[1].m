function cell_ent=calcentropy(cell_probs,N)

entrop=cell(N,1);

for n=1:N
    entrop{n}(:,1)=zeros(size(cell_probs{n},1),1);
end

for nn=1:N
    for ii=1:size(cell_probs{nn},1)
        if cell_probs{nn,1}(ii,1)==0 && cell_probs{nn,1}(ii,2)==0
            entrop{nn}(ii)=1;
        elseif isnan(cell_probs{nn,1}(ii,1))==1 && isnan(cell_probs{nn,1}(ii,2))==1
            entrop{nn}(ii)=1;
        else
            entrop{nn}(ii)=-cell_probs{nn,1}(ii,1)*log2(cell_probs{nn,1}(ii,1))-...
                cell_probs{nn,1}(ii,2)*log2(cell_probs{nn,1}(ii,2));
            if isnan(entrop{nn}(ii))==1
                entrop{nn}(ii)=0;
            end
        end
    end
end
cell_ent=entrop;