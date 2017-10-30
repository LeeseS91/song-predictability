function customshowalign(alignment,varargin)

seqNames = []; % by default no sequence names are given

if ischar(alignment)
    [numRows,alignmentLen] = size(alignment);
    alignment = upper(alignment);
    
    if numRows == 2
        % create our own match string
        matchString = blanks(alignmentLen);
        matches = (alignment(1,:) ~= alignment(2,:));
        similar = matches & false;
        matchString(matches) = '|';
        alignment = [alignment(1,:); matchString; alignment(2,:)];
        isMultipleAlignment = false;
        
    else
        isMultipleAlignment = true;
    end
else
    error('Bioinfo:showalignment:BadAlignmentFormat',...
        'ALIGNMENT should be a char array or an array of structures with the field ''Sequence''.')
end

if numRows < 2
    error('Bioinfo:showalignment:TooFewSequences',...
        'At least two sequences must be provided in ALIGNMENT.')
end

wrap = 64;


color =  'ff0000';%green
simcolor = 'ff00ff';
startat = [1;1];
% '55FF00';%green ff0000 red. 000000 black
noDisplay = false;  % use this for testing
terminalgap = true;

if nargin > 1
    if rem(nargin,2) == 0
        error('Bioinfo:showalignment:IncorrectNumberOfArguments',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'matchcolor','columns','nodisplay',...
        'similarcolor','startpointers','terminalgap'};
    for j=1:2:nargin-2
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs,numel(pname)));
        if isempty(k)
            error('Bioinfo:showalignment:UnknownParameterName',...
                'Unknown parameter name: %s.',pname);
        elseif length(k)>1
            error('Bioinfo:showalignment:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                
                case 1 %match color
                    color = setcolorpref(pval, color);
                case 2% wrap
                    if ~isMultipleAlignment
                        wrap = pval;
                    else
                        warning('Bioinfo:showalignment:MultiAlignColumns',...
                            'The ''COLUMNS'' option is not supported with multiple alignments.\nUse multialignviewer to view multiple alignments.');
                    end
                case 3% noDisplay
                    noDisplay = pval;
                case 4 %similar color
                    simcolor = setcolorpref(pval, simcolor);
                case 5 %startat
                    startat = pval(:);
                    if ~isnumeric(startat) || numel(startat) > 2
                        error('Bioinfo:showalignment:BadStartPointers',...
                            'Starting pointers should be a two element numeric array.');
                    elseif numel(startat) == 1
                        startat = [startat;startat]; %#ok
                    end
                case 6 %terminalgap
                    terminalgap = opttf(pval);
            end
        end
    end
end

if ~noDisplay
    import com.mathworks.mwswing.MJScrollPane;
    import java.awt.Color;
    import java.awt.Dimension;
    import com.mathworks.toolbox.bioinfo.sequence.*;
    
    % Create the viewer
    b = awtcreate('com.mathworks.toolbox.bioinfo.sequence.ShowLocalAlignment');
    
    % Set Java color for match and similar
    b.changeMatchColor(Color(hex2dec(color(1:2))/255, hex2dec(color(3:4))/255, hex2dec(color(5:6))/255));
    b.changeSimilarColor(Color(hex2dec(simcolor(1:2))/255, hex2dec(simcolor(3:4))/255, hex2dec(simcolor(5:6))/255));
    
    % show
    if isMultipleAlignment
        b.displayAlignment(alignment, matches, similar, wrap);
    else
        if terminalgap
            count = numel(matches);
        else
            mask = all(~(alignment([1 3],:)=='-' | alignment([1 3],:)==' '));
            count = find(mask,1,'last')-find(mask,1)+1;
        end
        b.displayAlignment(alignment, matches, similar, count, startat, wrap);
    end
    
    % Setup a scrollpane and put b into the scrollPane
    scrollpanel = MJScrollPane(b, MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED, MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    
    % Create a figure
    fTitle = sprintf('Aligned Sequences');
    hFigure = figure( ...
        'WindowStyle', 'normal', ...
        'Menubar', 'none', ...
        'Toolbar', 'none', ...
        'NumberTitle','off',...
        'Tag', 'seqshoworfs',...
        'Resize', 'on', ...
        'Name', fTitle,...
        'HandleVisibility', 'Callback',...
        'DeleteFcn',{@deleteView, b});
    % Set the figure widow size to fit the scrollPane
    d = awtinvoke(scrollpanel, 'getPreferredSize()');
    pos = getpixelposition(hFigure);
    if ~isMultipleAlignment
        pos(3) = d.getWidth;
    end
    pos(4) = d.getHeight;
    setpixelposition(hFigure,pos);
    
    figurePosition = get(hFigure, 'Position');
    [viewP, viewC] = javacomponent( scrollpanel, ...
        [0, 0, figurePosition(3), figurePosition(4)], ...
        hFigure);
    set(viewC, 'units', 'normalized');
    set(hFigure, 'userdata', viewC);
    % Get toolbox/matlab/icon path
    iconPath = fullfile(toolboxdir('matlab'),'icons');
    
    tb = uitoolbar(hFigure);
    cicon= load(fullfile(iconPath,'printdoc.mat')); % load cdata of print icon from toolbox/matlab/icon/printdoc.mat
    a1=uipushtool(tb, ...
        'CData', cicon.cdata, ...
        'TooltipString', 'Print',...
        'ClickedCallback', {@print_cb, b}); %#ok
end

%----------------------------------------------------
function print_cb(hSrv, event, b) %#ok
awtinvoke(b, 'printAlignment()');

%----------------------------------------------
function deleteView(hfig, event, b)%#ok
if ~isempty(b)
    awtinvoke(b, 'clearPrintView()');
end
viewC = get(hfig, 'userdata');
if ~isempty(viewC)
    delete(viewC)
end
