" jiangmiao/auto-pairs config

" Default pairs — extend or trim as needed
let g:AutoPairs = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '`': '`'}

" Jump out of a closing pair with <M-n>
let g:AutoPairsShortcutJump = '<M-n>'

" Toggle auto-pairs on/off with <M-p>
let g:AutoPairsShortcutToggle = '<M-p>'

" Fast-wrap the next expression into a pair with <M-e>
let g:AutoPairsShortcutFastWrap = '<M-e>'

" Don't use fly mode — it can feel surprising in practice
let g:AutoPairsFlyMode = 0

" Keep cursor centred after opening-pair <CR> expansion
let g:AutoPairsCenterLine = 1
