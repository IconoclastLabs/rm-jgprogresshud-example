class ExamplesController < UITableViewController

  EXAMPLES_CELL_ID = "ExamplesCell"
  DISMISS_TIMER = 3.0

  def viewDidLoad
    super

    @block_user_interaction = true

    rmq.stylesheet = ExamplesControllerStylesheet

    view.tap do |table|
      table.delegate = self
      table.dataSource = self
      rmq(table).apply_style :table
    end
  end


  def progressHUD(progress_hud, willPresentInView: view)
    p "#{progress_hud} will present in #{view}"
  end

  def progressHUD(progress_hud, didPresentInView: view)
    p "#{progress_hud} did present in #{view}"
  end

  def progressHUD(progress_hud, willDismissFromView: view)
    p "#{progress_hud} will dismiss from #{view}"
  end

    def progressHUD(progress_hud, didDismissFromView: view)
    p "#{progress_hud} did dismiss from #{view}"
  end

  def tableView(table_view, titleForHeaderInSection:section)
    case section
    when 0
      ""
    when 1
      "Extra Light Style"
    when 2
      "Light Style"
    when 3
      "Dark Style"
    end
  end

  def numberOfSectionsInTableView(tableView)
    4
  end

  def tableView(table_view, numberOfRowsInSection: section)
    case section
    when 0
      2
    else
      7
    end
  end

  def tableView(table_view, heightForRowAtIndexPath: index_path)
    rmq.stylesheet.examples_cell_height
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)

    cell = table_view.dequeueReusableCellWithIdentifier(EXAMPLES_CELL_ID) || begin
      rmq.create(ExamplesCell, :examples_cell, reuse_identifier: EXAMPLES_CELL_ID).get
    end

    if index_path.section == 0
      if index_path.row == 0
        cell.textLabel.text = "Block User Interaction"
        s = UISwitch.new
        s.on = @block_user_interaction
        s.addTarget(self, action: 'switched:', forControlEvents: UIControlEventValueChanged)
        cell.accessoryView = s
      else
        cell.textLabel.text = "Show a Keyboard"
      end
    else
      cell.textLabel.text = case index_path.row
      when 0
        "Fade, Activity Indicator"
      when 1
        "Fade, Act. Ind. & Text, Transform"
      when 2
        "Fade, Pie Progress, Dim Background"
      when 3
        "Zoom, Ring PRogress, Dim Background"
      when 4
        "Fade, Text Only, Bottom Position"
      when 5
        "Fade, Success, Square Shape"
      when 6
        "Fade, Error, Square Shape"
      end
    end

    cell
  end

  def tableView (table_view, didSelectRowAtIndexPath:index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)
    return if index_path.section == 0

    hud_style = index_path.section - 1

    case index_path.row
    when 0
      simple(hud_style)
    when 1
      with_text(hud_style)
    when 2
      progress(hud_style)
    when 3
      zoom_animation_with_ring(hud_style)
    when 4
      text_only(hud_style)
    when 5
      success(hud_style)
    when 6
      error(hud_style)
    end
  end

  def switched sender
    @block_user_interaction = sender.isOn

    JGProgressHUD.allProgressHUDsInViewHierarchy(self.navigationController.view).each do |visible|
      visible.userInteractionEnabled = @block_user_interaction
    end
  end

  def success style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    image_view = UIImageView.alloc.initWithImage(rmq.image.resource('jg_hud_success'))
    hud.textLabel.text = "Success!"
    indicator_view = JGProgressHUDIndicatorView.alloc.initWithContentView(image_view)
    hud.progressIndicatorView = indicator_view

    hud.square = true
    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def error style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    image_view = UIImageView.alloc.initWithImage(rmq.image.resource('jg_hud_error'))
    hud.textLabel.text = "Error!"
    indicator_view = JGProgressHUDIndicatorView.alloc.initWithContentView(image_view)
    hud.progressIndicatorView = indicator_view

    hud.square = true
    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def simple style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def with_text style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    hud.textLabel.text = "Loading..."

    action = proc {
      hud.useProgressIndicatorView = false
      hud.textLabel.text = "Done"
      hud.position = JGProgressHUDPositionBottomCenter
    }

    NSTimer.scheduledTimerWithTimeInterval(DISMISS_TIMER, target: action, selector: 'call:', userInfo: nil, repeats: false)
    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def progress style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    hud.progressIndicatorView = JGProgressHUDPieIndicatorView.alloc.initWithHUDStyle(style)
    hud.backgroundColor = UIColor.colorWithWhite(0, alpha: 0.4)
    hud.textLabel.text = "Uploading"

    action1 = proc {
      hud.setProgress(0.25, animated: true)
    }
    action2 = proc {
      hud.setProgress(0.5, animated: true)
    }
    action3 = proc {
      hud.setProgress(0.75, animated: true)
    }
    action4 = proc {
      hud.setProgress(1.0, animated: true)
    }
    action5 = proc {
      hud.dismiss
    }

    NSTimer.scheduledTimerWithTimeInterval(0.5, target: action1, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(1.0, target: action2, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(1.5, target: action3, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(2.0, target: action4, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(2.5, target: action5, selector: 'call:', userInfo: nil, repeats: false)

    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def zoom_animation_with_ring style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    hud.progressIndicatorView = JGProgressHUDRingIndicatorView.alloc.initWithHUDStyle(style)
    hud.backgroundColor = UIColor.colorWithWhite(0, alpha: 0.4)
    hud.animation = JGProgressHUDFadeZoomAnimation.animation
    hud.textLabel.text = "Downloading..."

    action1 = proc {
      hud.setProgress(0.25, animated: true)
    }
    action2 = proc {
      hud.setProgress(0.5, animated: true)
    }
    action3 = proc {
      hud.setProgress(0.75, animated: true)
    }
    action4 = proc {
      hud.setProgress(1.0, animated: true)
    }
    action5 = proc {
      hud.dismiss
    }

    NSTimer.scheduledTimerWithTimeInterval(0.5, target: action1, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(1.0, target: action2, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(1.5, target: action3, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(2.0, target: action4, selector: 'call:', userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(2.5, target: action5, selector: 'call:', userInfo: nil, repeats: false)

    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  def text_only style
    hud = JGProgressHUD.alloc.initWithStyle(style)
    hud.userInteractionEnabled = @block_user_interaction
    hud.delegate = self

    hud.useProgressIndicatorView = false
    hud.textLabel.text = "Hello World!"
    hud.position = JGProgressHUDPositionBottomCenter
    hud.marginInsets = UIEdgeInsetsMake(0, 20, 0 ,0)

    hud.showInView(self.navigationController.view)
    hud.dismissAfterDelay(DISMISS_TIMER)
  end

  # Remove if you are only supporting portrait
  def supportedInterfaceOrientations
    UIInterfaceOrientationMaskAll
  end

  # Remove if you are only supporting portrait
  def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
    rmq.all.reapply_styles
  end
end
