function! slime_cells#get_delimiter()
  if exists("b:slime_cell_delimiter")
    let cell_delimiter = b:slime_cell_delimiter
  elseif exists("g:slime_cell_delimiter")
    let cell_delimiter = g:slime_cell_delimiter
  else
    echoerr "b:slime_cell_delimeter is not defined"
    return ""
  endif
    return cell_delimiter
endfunction

function! slime_cells#select_current_cell(include_header=0) abort
  let cell_delimiter = slime_cells#get_delimiter()
  if cell_delimiter == ""
      return
  endif

  let [line_ini, col_ini] = searchpos(cell_delimiter, 'bcnW')
  let line_end = search(cell_delimiter, 'nW')

  if !line_ini
    let line_ini = 1
  elseif !a:include_header
    let line_ini = line_ini + 1
    let col_ini = 1
  end
  " line before delimiter or bottom of file
  let line_end = line_end ? line_end - 1 : line("$")
  let col_end = strlen(getline(line_end))

  call setpos("'<", [0, line_ini, col_ini, 0])
  call setpos("'>", [0, line_end, col_end, 0])
  normal! gv
  let current_mode = mode()
  if current_mode != "V"
    normal! V
  endif
endfunction

function! slime_cells#send_cell() abort
  call slime#store_curpos()
  call slime_cells#select_current_cell()
  call slime#send_op("", 1)
endfunction

function! slime_cells#go_to_next_cell()
  let cell_delimiter = slime_cells#get_delimiter()
  if cell_delimiter == ""
      return
  endif
  let line = search(cell_delimiter, 'eWn')
  if line == line(".")
    call cursor(line+1, 0)
    let line = search(cell_delimiter, 'eWn')
    call cursor(line(".")-1, 0)
  endif
  call cursor(line, 0)
endfunction

function! slime_cells#go_to_previous_cell()
  let cell_delimiter = slime_cells#get_delimiter()
  if cell_delimiter == ""
      return
  endif
  let line = search(cell_delimiter, 'Wbzn')
  if line == 0
    let line = 1
  endif
  call cursor(line, 0)
endfunction

function! slime_cells#send_cell_and_go_to_next()
  call slime_cells#send_cell()
  call slime_cells#go_to_next_cell()
endfunction

function! slime_cells#sign_on_cell_boundaries()
  if expand("%:p") != ""
    let cell_delimiter = slime_cells#get_delimiter()
    if cell_delimiter == ""
        return
    endif
    call sign_unplace("slime-cells")
    call map(getline(1, '$'), {idx, val ->val =~ cell_delimiter ? sign_place(0, "slime-cells", "SlimeCell", expand("%:p"), {"lnum": idx+1}) : 1})
  endif
endfunction

