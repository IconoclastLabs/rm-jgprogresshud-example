module ExamplesCellStylesheet
  def examples_cell_height
    80
  end

  def examples_cell(st)
    # Style overall cell here
    st.background_color = color.from_hex('#ddd')
  end

  def cell_label(st)
    st.color = color.black
  end
end
