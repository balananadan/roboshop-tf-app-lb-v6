module "db" {
  source = "./modules/vm"

  for_each       = var.db
  component_name = each.key

  rgname   = var.rgname
  image_id = var.image_id
  env      = var.env
}


module "apps" {
  source = "./modules/vm"

  for_each       = var.apps
  component_name = each.key

  rgname   = var.rgname
  image_id = var.image_id
  env      = var.env

  depends_on = [module.db]
}



module "ui" {
  source = "./modules/vm"

  for_each       = var.ui
  component_name = each.key

  rgname   = var.rgname
  image_id = var.image_id
  env      = var.env

  depends_on = [module.apps]
}
